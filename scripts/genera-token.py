#!/usr/bin/env python3
"""Genera tokens.css dai colori fissi di Bootstrap Italia.

Bootstrap Italia arriva compilato: i colori sono valori fissi ripetuti nel CSS
(il primario compare oltre duecento volte) e non c'è nessuna variabile da
sovrascrivere. Questo script rilegge il CSS ufficiale, prende tutte le regole
e riscrive ogni colore del design system come `var(--bi-…, valore originale)`,
lasciando tutto il resto com'è.

I colori nel CSS compaiono in notazioni diverse — `#06c`, `hsl(210, 100%, 40%)`,
`rgb(0, 102, 204)` sono lo stesso blu — quindi il confronto avviene sui valori
RGB normalizzati, non sul testo.

Il risultato, `bootstrap-italia-tokens.min.css`, sostituisce il CSS ufficiale
invece di aggiungersi: riemettere solo alcune regole cambierebbe l'ordine della
cascata fra regole di pari specificità.

Uso:
    python3 scripts/genera-token.py
"""

from __future__ import annotations

import colorsys
import pathlib
import re

BASE = pathlib.Path(__file__).resolve().parent.parent / "_extensions" / "bootstrap-italia"
SORGENTE = BASE / "bootstrap-italia" / "css" / "bootstrap-italia.min.css"
# accanto all'originale, così restano validi gli url() relativi che contiene
USCITA = BASE / "bootstrap-italia" / "css" / "bootstrap-italia-tokens.min.css"

# I colori del design system. La scala del primario segue la luminosità del blu
# istituzionale: `primary` è il colore base, i numeri più alti sono le varianti
# più scure.
TOKEN = [
    ("primary-050", "#EBF2FA"),
    ("primary-300", "#0080FF"),
    ("primary-350", "#0073E6"),
    ("primary-375", "#0070E0"),
    ("primary", "#0066CC"),
    ("primary-600", "#0059B3"),
    ("primary-700", "#004D99"),
    ("primary-800", "#004080"),
    ("primary-900", "#003366"),
    ("primary-dark", "#17324D"),
    ("primary-darker", "#0F3757"),
    ("secondary", "#5D7083"),
    ("secondary-dark", "#435A70"),
    ("secondary-darker", "#37424D"),
    ("success", "#008055"),
    ("warning", "#995C00"),
    ("danger", "#CC334D"),
    ("border", "#C5C7C9"),
    ("border-light", "#D8D9DA"),
    ("text", "#1A1A1A"),
]

COLORE = re.compile(r"#[0-9a-fA-F]{8}\b|#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b|(?:rgb|hsl)a?\([^)]*\)")

# blocchi at-rule il cui contenuto non è fatto di regole normali
SALTA = ("@keyframes", "@font-face", "@-webkit-keyframes", "@charset", "@import")


def to_rgb(colore: str) -> tuple[int, int, int] | None:
    """Converte un colore CSS in (r, g, b). None se ha trasparenza o non è riconosciuto."""
    c = colore.strip().lower()

    if c.startswith("#"):
        cifre = c[1:]
        if len(cifre) == 3:
            return tuple(int(x * 2, 16) for x in cifre)  # type: ignore[return-value]
        if len(cifre) == 6:
            return tuple(int(cifre[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]
        return None  # 8 cifre: ha un canale alfa

    m = re.match(r"(rgb|hsl)a?\(([^)]*)\)", c)
    if not m:
        return None
    tipo, dentro = m.group(1), m.group(2)
    parti = [p.strip() for p in re.split(r"[,/\s]+", dentro) if p.strip()]
    if len(parti) > 3:  # con alfa: si lascia stare
        return None
    try:
        if tipo == "rgb":
            valori = []
            for p in parti:
                grezzo = float(p[:-1]) * 255 / 100 if p.endswith("%") else float(p)
                valori.append(int(grezzo + 0.5))
            return tuple(valori)  # type: ignore[return-value]
        tinta = float(parti[0].replace("deg", "")) / 360
        sat = float(parti[1].rstrip("%")) / 100
        lum = float(parti[2].rstrip("%")) / 100
        r, g, b = colorsys.hls_to_rgb(tinta, lum, sat)
        return (int(r * 255 + 0.5), int(g * 255 + 0.5), int(b * 255 + 0.5))
    except (ValueError, IndexError):
        return None


RGB_TOKEN = [(to_rgb(valore), nome) for nome, valore in TOKEN]


def nome_token(colore: str) -> str | None:
    """Nome del token corrispondente al colore, se c'è.

    Il confronto ammette uno scarto di un punto per canale: la compilazione SASS
    produce valori frazionari (`rgb(0,76.5,153)`) che i browser arrotondano per
    eccesso, e che qui verrebbero arrotondati diversamente."""
    rgb = to_rgb(colore)
    if rgb is None:
        return None
    for riferimento, nome in RGB_TOKEN:
        if riferimento and all(abs(a - b) <= 1 for a, b in zip(rgb, riferimento)):
            return nome
    return None


SENZA_URL = re.compile(r"url\([^)]*\)")


def tokenizza(css: str) -> tuple[str, int]:
    """Sostituisce i colori del design system con var(--bi-…) in tutto il CSS.

    I colori dentro `url(...)` (immagini SVG in linea) restano intatti: lì le
    variabili CSS non valgono."""
    sostituzioni = 0

    def rimpiazza(m: re.Match[str]) -> str:
        nonlocal sostituzioni
        nome = nome_token(m.group(0))
        if not nome:
            return m.group(0)
        sostituzioni += 1
        return f"var(--bi-{nome}, {m.group(0)})"

    pezzi = []
    posizione = 0
    for url in SENZA_URL.finditer(css):
        pezzi.append(COLORE.sub(rimpiazza, css[posizione : url.start()]))
        pezzi.append(url.group(0))
        posizione = url.end()
    pezzi.append(COLORE.sub(rimpiazza, css[posizione:]))
    return "".join(pezzi), sostituzioni


def main() -> None:
    css, sostituzioni = tokenizza(SORGENTE.read_text())

    testa = [
        "/* Bootstrap Italia con i colori esposti come variabili CSS.",
        " *",
        " * File generato da scripts/genera-token.py a partire da",
        " * bootstrap-italia.min.css: non modificarlo a mano.",
        " *",
        " * Bootstrap Italia arriva compilato, con i colori scritti come valori fissi e",
        " * nessuna variabile da sovrascrivere. Qui ogni colore del design system è",
        " * diventato var(--bi-…, valore originale): i colori istituzionali si cambiano",
        " * ridefinendo le variabili, senza ricompilare nulla.",
        " *",
        " *   :root {",
        " *     --bi-primary: #7A0026;",
        " *     --bi-primary-600: #6B0022;",
        " *     --bi-primary-700: #5C001D;",
        " *     --bi-primary-800: #4D0018;",
        " *   }",
        " */",
        "",
        ":root {",
    ]
    testa += [f"  --bi-{nome}: {valore};" for nome, valore in TOKEN]
    testa += ["}", ""]

    USCITA.write_text("\n".join(testa) + "\n" + css)
    print(f"{USCITA.name}: {sostituzioni} colori sostituiti, {USCITA.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
