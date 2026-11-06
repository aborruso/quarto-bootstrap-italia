#!/usr/bin/env python3
"""Segnala i colori fissi nel CSS del tema: devono passare dalle variabili --bi-…,
altrimenti non seguono la palette dell'ente. Ammessi il bianco e le ombre neutre."""

import re
import sys
from pathlib import Path

CSS = Path("_extensions/bootstrap-italia/quarto-bootstrap-italia.css")
COLORE = re.compile(r"#[0-9a-fA-F]{3,8}\b|\b(?:rgb|hsl)a?\([^)]*\)")
AMMESSI = re.compile(r"^(#fff|#ffffff|rgba\(0, 0, 0, [0-9.]+\))$", re.I)

testo = re.sub(r"/\*.*?\*/", lambda m: re.sub(r"[^\n]", " ", m.group(0)), CSS.read_text(encoding="utf-8"), flags=re.S)
# la definizione delle variabili del tema e il valore di riserva di var(--bi-…) sono leciti
testo = re.sub(r":root\s*\{.*?\}", lambda m: re.sub(r"[^\n]", " ", m.group(0)), testo, flags=re.S)
testo = re.sub(r"var\(--bi-[a-z0-9-]+(?:,[^()]*(?:\([^()]*\))?[^()]*)?\)", "var()", testo)

errori = 0
for numero, riga in enumerate(testo.splitlines(), 1):
    for colore in COLORE.findall(riga):
        if not AMMESSI.match(colore):
            print(f"FALLITO {CSS}:{numero}: colore fisso {colore}")
            errori += 1
    # le opacità di `.bg-opacity-*` e simili non sono colori
    if re.search(r"var\(--bs-(?!(?:bg|text|border)-opacity\b)", riga):
        print(f"FALLITO {CSS}:{numero}: --bs-… non segue la palette, serve --bi-…")
        errori += 1

if errori:
    sys.exit(1)
print("ok      nessun colore fisso nel CSS del tema")
