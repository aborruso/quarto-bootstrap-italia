# Bootstrap Italia per Quarto

Formato Quarto che veste siti e documenti HTML con [Bootstrap Italia](https://italia.github.io/bootstrap-italia/), il framework del design system `.italia` conforme alle [Linee guida di design per i siti internet e i servizi digitali della PA](https://designers.italia.it/norme-e-riferimenti/) (art. 53 CAD).

Il Bootstrap incluso da Quarto viene rimosso del tutto (`theme: none`) e sostituito da Bootstrap Italia 2.18.3, con font, icone e JavaScript del design system già collegati.

Sito di esempio e guida: <https://aborruso.github.io/quarto-bootstrap-italia/>

## Installazione

```bash
quarto add aborruso/quarto-bootstrap-italia
```

Serve Quarto 1.10 o successivo: il tema usa la fase `pre-ast` per i filtri e `quarto.project.offset`, ed è stato verificato su 1.10.20.

Poi nel documento o in `_quarto.yml`:

```yaml
format:
  bootstrap-italia-html: default
```

## Sito di esempio

Per partire da un sito già impostato:

```bash
quarto use template aborruso/quarto-bootstrap-italia
```

Vengono creati l'estensione, un `_quarto.yml` commentato, una home e una pagina di notizie: si cambia il nome dell'ente nel YAML e il sito è pronto. Il sito dimostrativo non viene copiato: sta in [`_demo/`](_demo/) e si vede su <https://aborruso.github.io/quarto-bootstrap-italia/>.

## Cosa porta con sé

| Risorsa | Come arriva nella pagina |
| --- | --- |
| `bootstrap-italia.min.css` | opzione `css` del formato |
| Font Titillium Web, Lora, Roboto Mono | `fonts.css`, `@font-face` statiche |
| JavaScript del design system | dipendenza HTML dichiarata dal filtro Lua |
| Sprite delle 179 icone | inserito nel body dal filtro Lua |
| Ricerca full text sull'indice `search.json` | `bootstrap-italia-search.js`, stessa dipendenza |

## Ricerca full text

Quarto genera l'indice `search.json` per ogni sito, ma la sua interfaccia di ricerca è agganciata al tema Bootstrap di Quarto e sparisce con `theme: none`. L'estensione ne fornisce una propria, che legge lo stesso indice e usa i componenti di Bootstrap Italia.

Serve solo che la ricerca sia attiva (`search: true` in `_quarto.yml`, è il default): il pulsante nell'intestazione lo genera il tema.

Si può aprire anche da codice con `window.biOpenSearch()`.

## Intestazione, menu e piè di pagina

Nel progetto non si scrive HTML: il tema genera tutto da `_quarto.yml`, sui siti (`project: type: website`). Un documento singolo non ha né intestazione né piè di pagina.

```yaml
website:
  title: "Nome del sito"
  search: true
  navbar:
    left:
      - text: Home
        href: index.qmd
      - text: Novità
        menu:
          - text: Notizie
            href: notizie/index.qmd
  page-footer:
    center:
      - text: Note legali
        href: note-legali.qmd

bootstrap-italia:
  ente:
    text: Ente di appartenenza
    href: https://www.example.org
  istituzione: Nome dell'Istituzione
  tagline: Il sottotitolo
  logo: it-pa
  lingue:
    - lang: it
      text: ITA
      href: index.qmd
    - lang: en
      text: ENG
      href: en/index.qmd
  footer:
    - title: Contatti
      text: |
        **Nome dell'Istituzione**\\
        Via Roma 1 - 00100 Città
    - title: Link utili
      links:
        - text: Albo pretorio
          href: albo.qmd
    - title: Seguici su
      social:
        - icon: it-github
          text: GitHub
          href: https://github.com/
```

| Chiave | Cosa produce |
| --- | --- |
| `website.navbar` | il menu, con la sintassi standard di Quarto; la voce attiva è calcolata al render |
| `website.page-footer.center` | i link in fondo alla pagina |
| `bootstrap-italia.ente`, `lingue` | la barra in alto; il selettore compare solo se ci sono lingue |
| `bootstrap-italia.istituzione`, `tagline`, `logo` | il marchio; `logo` è un'icona `it-…` o il percorso di un'immagine |
| `bootstrap-italia.footer` | le colonne del piè di pagina: `text`, `links`, `social` |

`website` si legge direttamente da `_quarto.yml`, perché non arriva ai filtri: i profili e `metadata-files` non lo modificano. `bootstrap-italia` passa invece dai metadati, e li rispetta.

## Notizie e immagini

Le notizie si scrivono con le funzioni native di Quarto: `listing: type: grid` per l'elenco, `categories`, `image` e `image-alt` in front matter. Figure, didascalie e citazioni escono in Markdown con gli stili del design system:

```markdown
![La sala di lettura.](img/sala.jpg){.rounded fig-alt="Descrizione dell'immagine"}

> Il testo citato.
>
> [Nome della fonte]{.blockquote-footer}
```

Le notizie e le immagini di questo sito sono inventate; le immagini in `_demo/notizie/img/` sono generate al computer e servono solo da esempio.

## Codice eseguito

Tabelle e grafici di knitr e Jupyter escono con gli stili del design system, nelle pagine [`dati-python.qmd`](_demo/dati-python.qmd) e [`dati-r.qmd`](_demo/dati-r.qmd). Le due pagine usano `freeze: auto`: il risultato è in `_freeze/`, che va tenuto nel repository, e il sito si rigenera senza Python né R finché il sorgente non cambia. Chi modifica una di quelle pagine deve avere il motore: con Python, `QUARTO_PYTHON` indica l'interprete con `jupyter`, `pandas` e `matplotlib`.

Due avvertenze per chi scrive:

- ogni figura ha bisogno del proprio testo alternativo: `fig-alt`, anche in forma di elenco quando una cella produce più figure
- `great_tables` inserisce nella pagina un CSS che toglie i bordi a tutte le tabelle, non solo alla propria: conviene non usarlo accanto ad altre tabelle

## Icone

Lo sprite è già dentro la pagina, quindi le icone si richiamano con un riferimento interno, senza percorsi:

```html
<svg class="icon"><use href="#it-search"></use></svg>
```

L'elenco dei nomi è nella [documentazione delle icone](https://italia.github.io/bootstrap-italia/docs/utilities/icone/).

Se lo sprite non serve — per esempio in un documento senza icone — si disattiva:

```yaml
bootstrap-italia-sprites: false
```

## Contenuti di Quarto

La sintassi standard di Quarto produce componenti del design system: non serve scrivere HTML.

| Si scrive | Si ottiene |
| --- | --- |
| `::: {.callout-note}` … `.callout-tip`, `.callout-warning`, `.callout-caution`, `.callout-important` | il callout di Bootstrap Italia, con icona e variante corrispondenti |
| una tabella Markdown | la tabella del design system (classe `.table` aggiunta dal tema) |
| `![didascalia](img.svg){#fig-x}` | figura e didascalia, riferimenti incrociati compresi |
| `::: {.panel-tabset}` | le schede, con la barra dei tab del design system |
| `toc: true` | l'indice della pagina, in un riquadro con la barra istituzionale |
| blocchi di codice, `code-fold` | box con sfondo, bordo e pulsante di copia |
| ```` ```{.python .numberLines} ```` | numeri di riga in colonna, separati dal codice |
| note a piè di pagina, citazioni, liste di definizione | tipografia del design system |
| `$…$` e `$$…$$` | formule in MathML, nativo nei browser: nessuna libreria esterna |
| `listing:` (elenchi di articoli, notizie, documenti) | elenco con data, titolo e descrizione nello stile del design system |
| ```` ```{mermaid} ```` | diagrammi, resi da Quarto |

La pagina `_demo/demo.qmd` raccoglie tutti questi casi in un unico posto: è il banco di prova da rigenerare quando si aggiorna il tema o Bootstrap Italia, ed è raggiungibile dal menu alla voce «Contenuti Quarto». Fa parte anche del template, come esempio di riferimento: chi non la vuole nel proprio sito cancella `demo.qmd`, la cartella `img/` e la voce di menu in `partials/header.html`.

## Componenti nel Markdown

Le classi del design system si usano con i div fenced di Quarto:

```markdown
::: {.card-wrapper .card-space}
::: {.card .card-bg}
::: {.card-body}
<h3 class="card-title h5">Titolo</h3>
<p class="card-text">Testo della card.</p>
:::
:::
:::
```

Per i **callout** non serve: si usa la sintassi di Quarto e ci pensa il tema.

```markdown
::: {.callout-warning title="Attenzione"}
Testo del callout.
:::
```

Un filtro Lua li riscrive con il markup di Bootstrap Italia, che è diverso da quello di Bootstrap: le varianti sono `note`, `important`, `warning`, `success`, `danger` — non `callout-warning` — e il box con il bordo colorato lo disegna `callout-inner`. La mappatura è `note → note`, `tip → success`, `warning → warning`, `caution → important`, `important → danger`.

Un callout con un identificatore si richiama come una figura: `::: {#tip-uno .callout-tip}` e nel testo `@tip-uno`, che diventa «Suggerimento 1». I prefissi sono `nte-`, `tip-`, `wrn-`, `cau-` e `imp-`, e il riferimento vale nella stessa pagina. Le etichette sono in italiano; si cambiano con `language: crossref-tip-prefix:` e simili.

Un div fenced con classe `callout` scritto a mano viene invece intercettato dai callout nativi di Quarto e trasformato in un blockquote: se serve il markup grezzo, va messo in un blocco ```` ```{=html} ````.

## Colori istituzionali

Bootstrap Italia arriva compilato, con i colori scritti come valori fissi: il blu istituzionale compare oltre duecento volte e non c'è nessuna variabile da sovrascrivere. L'estensione include una versione del CSS in cui ogni colore del design system è diventato una variabile, quindi la palette si cambia in un foglio di stile proprio:

```css
:root {
  --bi-primary: #7A0026;
  --bi-primary-600: #6B0022;
  --bi-primary-700: #5C001D;
  --bi-primary-800: #4D0018;
  --bi-primary-900: #3D0013;
}
```

```yaml
format:
  bootstrap-italia-html:
    css: colori-ente.css
```

Cambiano insieme intestazione, menu, piè di pagina, collegamenti, bottoni, callout e tutto il resto. Le variabili disponibili:

| Variabile | Valore | Dove si vede |
| --- | --- | --- |
| `--bi-primary` | `#0066CC` | intestazione, collegamenti, bottoni |
| `--bi-primary-050` … `--bi-primary-900` | dal `#EBF2FA` al `#003366` | sfondi tenui, stati attivi, piè di pagina |
| `--bi-primary-dark`, `--bi-primary-darker` | `#17324D`, `#0F3757` | testi e fondali scuri |
| `--bi-secondary`, `--bi-secondary-dark`, `--bi-secondary-darker` | `#5D7083`, `#435A70`, `#37424D` | testi secondari |
| `--bi-success`, `--bi-warning`, `--bi-danger` | `#008055`, `#995C00`, `#CC334D` | callout e messaggi |
| `--bi-border`, `--bi-border-light` | `#C5C7C9`, `#D8D9DA` | bordi e separatori |
| `--bi-text` | `#1A1A1A` | testo corrente |
| `--bi-surface`, `--bi-surface-dark` | `#F5F6F7`, `#E9ECEF` | fondi di codice, indice e schede |
| `--bi-caption` | grigio al 32% | didascalie |

Cambiando la palette va controllato il contrasto: le combinazioni del design system sono verificate, le proprie no. Il [profilo di accessibilità](#controllare-laccessibilità) segnala i contrasti insufficienti.

Il file è generato da `scripts/genera-token.py`, che rilegge il CSS ufficiale e sostituisce i colori confrontandoli sui valori RGB, qualunque sia la notazione. Va rieseguito quando si aggiorna Bootstrap Italia.

Non è possibile usare SCSS: in Quarto lo SCSS viene compilato solo attraverso l'opzione `theme`, che reintrodurrebbe il Bootstrap di Quarto sopra a quello di Bootstrap Italia.

## Cosa resta di Quarto

Il formato mantiene `site_libs/quarto-html/` (tooltip, tabset, copia del codice) e `site_libs/clipboard/`, che non confliggono con Bootstrap Italia. Si eliminano solo con `minimal: true`, che però disattiva anche quelle funzionalità.

Il blocco titolo generato da Quarto viene allineato al `.container` del design system. Se si preferisce gestire il titolo nel contenuto:

```yaml
title-block-style: none
```

## Controllare l'accessibilità

Quarto 1.10 include axe-core (4.10.3) e sa produrre da solo il report di accessibilità, senza rete. Il sito dimostrativo ha un profilo pronto, `_demo/_quarto-a11y.yml`:

```bash
quarto render _demo --profile a11y
```

Le pagine così generate stampano in console il risultato in JSON, controllato sul livello **WCAG 2.1 AA**. Per vedere le violazioni evidenziate direttamente nella pagina, si cambia `output: json` in `output: document`.

Il report è indipendente dal tema — funziona anche con `theme: none` — quindi è lo strumento da usare per verificare il tema a ogni aggiornamento. Le pagine generate con il profilo non vanno pubblicate: contengono lo script di controllo.

## Verifiche fatte

Su Quarto 1.10.18, Chrome, viewport desktop e 390×844 (sulla 1.10.20 l'HTML delle pagine è identico e axe-core, rilanciato, non trova violazioni):

- **accessibilità**: nessuna violazione su tutte le pagine, sia con il report axe integrato di Quarto (WCAG 2.1 AA) sia con axe-core eseguito a mano; ricerca usabile da tastiera (Invio apre, Escape chiude, il focus torna alla lente); skip link funzionante; header istituzionale dentro un landmark `<header>`
- **validazione HTML**: nessun errore, nessun id duplicato; restano avvisi di `tidy` dovuti agli attributi proprietari di Quarto e ai limiti di `tidy` su SVG
- **mobile**: menu a scomparsa, ricerca e tabelle senza scorrimento orizzontale
- **contenuti**: la pagina `demo.qmd` non mostra elementi privi di stile

Due avvertenze di accessibilità che riguardano il **contenuto**, non il tema:

- le immagini vogliono `fig-alt`, altrimenti Quarto genera un `<img>` senza `alt`
- un `listing:` usa `<h3>` per i titoli: se nella pagina non c'è un `<h2>` prima, la gerarchia dei titoli risulta saltata

Non ancora verificati: altri browser, stampa, output di codice eseguito (knitr/jupyter), pagine `about`, modalità scura.

## Struttura del repository

| Dove | Cosa |
| --- | --- |
| `_extensions/` | il tema, cioè ciò che `quarto add` installa |
| `_quarto.yml`, `index.qmd`, `notizie/` | lo starter, cioè ciò che `quarto use template` copia insieme al tema |
| `_demo/` | il sito dimostrativo pubblicato; `_demo/_extensions` è un collegamento simbolico a `_extensions/` |

Il prefisso `_` tiene `_demo/` fuori dal render dello starter. Il sito si genera con `quarto render _demo`. Su Windows il collegamento simbolico richiede `core.symlinks` attivo in Git. Le pagine `_demo/dati-*.qmd` si rendono da `_demo/_freeze/` finché il loro sorgente non cambia.

## Licenze

Il codice dell'estensione è distribuito con licenza BSD-3-Clause, come Bootstrap Italia, di cui include il pacchetto compilato. I font inclusi hanno licenza SIL Open Font License 1.1 (Titillium Web, Lora, Roboto Mono).
