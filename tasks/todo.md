# Tema Quarto Bootstrap Italia

## Obiettivo

Un formato Quarto riutilizzabile che veste siti e documenti HTML con Bootstrap Italia, installabile da altri con `quarto add`.

## Fase 1 — Ricognizione

- [x] Quarto 1.10.18 installato in `./quarto`
- [x] Come si sostituisce il CSS in Quarto (deepwiki su `quarto-dev/quarto-web`):
  - `theme: <nome|scss>` → tema Bootstrap gestito da Quarto (25 Bootswatch + layering SCSS)
  - `css: file.css` → si sovrappone al tema, per ritocchi
  - `theme: none` → rimuove del tutto il Bootstrap di Quarto; resta la struttura HTML, senza stile; `toc-location` non è più disponibile
  - `minimal: true` → più drastico: toglie anche i JS di Quarto (anchor, tabset, copy code)
  - `include-in-header` / `include-before-body` / `include-after-body`, `resources`, `format-resources`
- [x] Bootstrap Italia stabile: v2.18.3 (Bootstrap 5.2.3)
- [x] Requisiti di una format extension e di un template (deepwiki)

## Fase 2 — Prototipo (sito singolo)

- [x] Asset Bootstrap Italia estratti, `theme: none` + `css:` + partial header/footer
- [x] Render, verifica su HTTP con agent-browser: font, icone, JS, zero 404

## Fase 3 — Migrazione da JavaScript a CSS

- [x] `fonts.css`: le `@font-face` che BI iniettava con `bootstrap.loadFonts()` estratte dal DOM e rese statiche
- [x] Rimossi `window.__PUBLIC_PATH__` e la chiamata `loadFonts()`
- [x] Verificato: zero `<style>` iniettati, font `loaded` lo stesso
- [x] Provato SCSS in `css:` → **non funziona**: Quarto copia il `.scss` e lo linka tal quale. Lo SCSS passa solo da `theme:`, che rimetterebbe il Bootstrap di Quarto

## Fase 4 — Estensione riutilizzabile

- [x] `_extensions/bootstrap-italia/_extension.yml` → formato `bootstrap-italia-html`
- [x] CSS e font via `css:` → Quarto risolve gli `url()` e copia i file dei font accanto al CSS
- [x] `format-resources` **scartato**: copia i file nella cartella del progetto di chi usa il tema (sporca la root con `fonts/`, `js/`, `svg/`)
- [x] Filtro Lua `bootstrap-italia.lua`:
  - `quarto.doc.add_html_dependency` per il bundle JS → finisce in `site_libs/quarto-contrib/bootstrap-italia-2.18.3/`, tag `<script>` automatico
  - sprite delle 179 icone inserito nel body → si scrive `<use href="#it-search">`, senza percorsi, e funziona in ogni sottocartella
  - opzione `bootstrap-italia-sprites: false` per disattivarlo
- [x] Starter nella root: `_quarto.yml`, `index.qmd`, `partials/header.html`, `partials/footer.html`
- [x] `README.md`, `LICENSE` (BSD-3-Clause, come Bootstrap Italia), `.gitignore`, `.quartoignore`

## Fase 5 — Verifica

- [x] `quarto render` pulito
- [x] `quarto preview --no-browser --port 8766` parte senza problemi nonostante `quarto/` da 447 MB nel progetto
- [x] Browser (agent-browser su server statico): 10 icone renderizzate, sprite inline presente, 6 font `loaded`, `window.bootstrap` attivo, dropdown della navbar che apre e chiude
- [x] Screenshot full page: header, footer, card, callout, bottoni

## Fase 6 — Ricerca e sito multi-pagina

- [x] Scoperto perché `search.json` non veniva generato: Quarto indicizza il contenuto di `<main>`, che con `theme: none` non c'era. I partial ora aprono `<main id="main-content" class="container my-5">` e lo chiudono nel footer
- [x] Scoperto perché l'interfaccia di ricerca non compariva: in `websiteProjectType.formatExtras` la scelta è `formatHasBootstrap(format) ? websiteNavigationExtras : websiteNoThemeExtras` — senza il Bootstrap di Quarto la search non viene mai agganciata
- [x] Ricerca propria nel tema: `bootstrap-italia-search.js` legge `search.json` e mostra i risultati in un modal Bootstrap Italia; si aggancia a `[data-bi-search]`, si apre anche con `window.biOpenSearch()`
- [x] Percorso dell'indice passato dal Lua con `quarto.project.offset`; letto al momento dell'uso perché Quarto inserisce lo `<script>` della variabile **dopo** il file JS
- [x] Verificato dalla home (4 risultati per "lorem") e da una pagina in sottocartella (2 risultati per "consiglio", link `../eventi.html`)
- [x] Quattro pagine lorem ipsum: `amministrazione.qmd`, `servizi.qmd`, `notizie.qmd`, `eventi.qmd`, collegate alle voci di menu
- [x] Voce di menu attiva calcolata a runtime in base al percorso della pagina
- [x] Rimosso il CSS che ricostruiva a mano i breakpoint del container: il blocco titolo ora sta dentro `<main class="container">`

## Fase 7 — Contenuti Quarto in Markdown standard

- [x] Callout scritti con `::: {.callout-warning}` e riscritti dal filtro `bootstrap-italia-callout.lua` con il markup di Bootstrap Italia
  - la fase giusta è **`at: pre-ast`**: con `pre-quarto` il filtro vedeva solo `Div hidden`, i callout erano già stati degradati a blockquote
  - mappatura: `note → note`, `tip → success`, `warning → warning`, `caution → important`, `important → danger`
- [x] Doppio `<header id="title-block-header">` (id duplicato) risolto: senza il tema di Quarto il title block esce dal partial pandoc senza classe, e `canonicalizeTitlePostprocessor` ne crea un secondo dentro `<main>`. Il tema fornisce un `template-partials: partials/title-block.html` con `class="quarto-title-block"`
- [x] `demo.qmd`: tutti i tipi di contenuto Quarto in una pagina, per verificare la coerenza col design system
- [x] Difetti trovati nella demo e risolti:
  - tabelle senza la classe `.table` → aggiunta dal filtro Lua: erano senza bordi né spaziature
  - blocchi di codice senza box → CSS di raccordo
  - schede `.panel-tabset-tabby` senza stile → CSS che replica i tab del design system
  - indice `nav#TOC` senza stile → riquadro con barra istituzionale
  - didascalie `.quarto-float-caption` centrate e senza gerarchia → allineate e in grigio
  - formule non renderizzate (`Could not convert TeX math`) → `html-math-method: mathjax` (Quarto lo carica da CDN)
- [x] `docs/prd.md`: requisito centrale — Bootstrap Italia usando Quarto nel modo più standard possibile

## Fase 8 — Review di compatibilità

- [x] **Mobile (390×844)**: header collassato, menu a scomparsa, ricerca nel modal, nessuno scorrimento orizzontale su nessuna pagina
- [x] **Tastiera**: skip link al primo Tab, focus visibile (outline 3px), ricerca apribile con Invio e chiudibile con Escape
  - difetto trovato e corretto: alla chiusura il focus finiva sul `body`. Ora torna alla lente (WCAG 2.4.3)
- [x] **axe-core** su tutte le pagine: zero violazioni
  - `region`: il contenuto dell'header non stava in un landmark → `.it-header-wrapper` è diventato un `<header>`
  - `image-alt` e `aria-progressbar-name`: erano difetti del contenuto della demo, non del tema → `fig-alt` sulle immagini, `aria-label` sulla barra di avanzamento
  - `heading-order` sul listing: i titoli dei post sono `<h3>`, serve un `<h2>` prima → aggiunto nella pagina
  - `aria-hidden-focus`: falso positivo, elementi `data-tabster-dummy` iniettati dall'ambiente di test, assenti nell'HTML e nei JS del sito
- [x] **Validazione HTML** (`tidy`): nessun errore, nessun id duplicato. Restano avvisi da attributi proprietari di Quarto (`append-hash`, `alt` sul div della figura) e limiti di tidy su SVG
- [x] **Listing**: erano appesi in fondo al `body`. Quarto li inserisce in `#quarto-content main.content`: la struttura è stata aggiunta ai partial, più CSS di raccordo per data, titolo, descrizione e separatori
- [x] **Diagrammi mermaid**: funzionano senza interventi
- [x] `notizie.qmd` sostituita da un vero listing (`notizie/index.qmd` + due articoli), così il caso resta coperto dal sito di esempio

Non verificati: altri browser, stampa, output di codice eseguito (knitr/jupyter), pagine `about`, modalità scura.

## Fase 9 — Le novità di accessibilità di Quarto 1.10

Dal changelog 1.10, la sezione «Accessibility» è quasi tutta dedicata all'opzione `axe`:

- axe-core 4.10.3 **incluso in Quarto**: il controllo funziona offline, non si carica più da CDN (#14677)
- il report mostra il livello di conformità WCAG di ogni violazione (#14604)
- nuove opzioni `standard: wcag21aa` e `best-practice` (#14607)
- violazioni ordinate per gravità (#14676)
- colori del report indipendenti dal tema: **è per questo che funziona anche con `theme: none`** (#14468)
- nomi accessibili sui link ai numeri di riga del codice (#14655)
- corretto il link ORCID senza nome accessibile nel title block (#14602)

Verifiche fatte:

- [x] `axe: {output: document}` funziona con `bootstrap-italia-html`: l'overlay compare e segnala correttamente (provato con un'immagine senza `alt`)
- [x] Profilo `_quarto-a11y.yml` (`output: json`, `standard: wcag21aa`) → `quarto render --profile a11y`
- [x] Controllo ufficiale su tutte e 7 le pagine: **nessuna violazione**, conferma indipendente dell'audit manuale
- [x] Blocco di codice con numeri di riga aggiunto alla demo: nessuna violazione, il fix #14655 vale anche qui
- Il fix ORCID (#14602) riguarda il title block di Quarto: il tema usa un partial proprio, che non mostra gli ORCID né prima né dopo — non è una regressione, ma è un dato da tenere presente se servirà

## Cosa resta da fare

### Per poter dire ad altri «installatelo»

- [ ] Creare il repository `aborruso/quarto-bootstrap-italia` e fare il primo push
- [ ] Verificare `quarto add` e `quarto use template` **dal remoto**: finora provati solo da locale
- [ ] CI su GitHub Actions: render del sito + `--profile a11y`, con esito negativo se compare una violazione o se la demo perde pezzi. È il presidio contro le rotture silenziose: il tema si aggancia a dettagli interni di Quarto (`#quarto-content main.content`, `canonicalizeTitlePostprocessor`, `at: pre-ast`, `quarto.project.offset`) che non sono contratto pubblico
- [ ] Confermare la licenza: `LICENSE` è BSD-3-Clause a nome di Andrea Borruso, scelta per coerenza con Bootstrap Italia che il tema ridistribuisce

### Compatibilità non ancora verificata

- [ ] **Output di codice eseguito** (knitr/jupyter): tabelle `df-print`, grafici, output delle celle. È il caso d'uso principale di Quarto e qui è un buco. Sospetto concreto: le tabelle prodotte da pandas o knitr arrivano come HTML grezzo e non passano dal filtro `Table`, quindi restano senza la classe `.table`
- [ ] Pagine `about`, modalità scura, stampa, browser diversi da Chrome

### Prodotto

- [ ] **Colori istituzionali**: oggi cambiarli richiede di ricompilare Bootstrap Italia dai sorgenti SCSS. Per il profilo di utente descritto nel PRD è troppo: serve almeno la procedura documentata passo passo, o valutare di esporre i design token come variabili CSS sovrascrivibili
- [ ] **Ricerca**: il ranking è elementare (sottostringa, niente fuzzy né stemming) e non evidenzia i termini trovati
- [ ] **Bootstrap Italia 3.x**: oggi in beta (3.0.0-beta.4), da affrontare quando esce stabile
- [ ] Il partial `title-block.html` è essenziale: non mostra autori con ORCID né altri metadati ricchi. Da estendere se servirà
- [ ] `quarto-required: ">=1.10.0"` è prudenziale: verificato solo su 1.10.18, non si sa da quale versione funzionino `at: pre-ast` e `quarto.project.offset`

## Review

**Struttura finale**

```
_extensions/bootstrap-italia/     ← il tema (si installa con quarto add)
  _extension.yml                  formato bootstrap-italia-html
  bootstrap-italia.lua            JS + sprite icone
  bootstrap-italia/               dist di Bootstrap Italia 2.18.3
  fonts.css                       @font-face statiche
  quarto-bootstrap-italia.css     raccordo con il markup di Quarto
_quarto.yml, index.qmd, partials/ ← lo starter (quarto use template)
README.md, LICENSE, .gitignore, .quartoignore
quarto/                           installazione locale, esclusa da git e dal render
```

**Le quattro trappole**

1. **Quarto installato dentro il progetto** — `render` provava a processare i `.qmd` dei template interni. Risolto con `project: render:` che esclude `quarto/**`.
2. **I font non si caricavano** — BI non ha `@font-face` nel CSS: le inietta da JS con `loadFonts()`. Ora sono statiche in `fonts.css`, e il JS serve solo ai comportamenti.
3. **Callout** — due problemi distinti. Quarto intercetta **qualunque** div fenced con classe `callout` (non solo `callout-*`) e lo trasforma in un blockquote con "None": va scritto come HTML grezzo. E il markup di Bootstrap Italia non è quello di Bootstrap: le varianti sono `note`/`important`/`warning`/`success`/`danger` — non `callout-warning` — e il box con il bordo colorato lo disegna `callout-inner`, senza il quale il callout resta senza cornice.
4. **Percorsi degli asset in un'estensione** — `format-resources` copia nella cartella dell'utente; i CSS finiscono in `site_libs/quarto-contrib/quarto-project/...` e i `<use href="file.svg#id">` non avrebbero un percorso stabile. Risolto con la dipendenza HTML per il JS e lo sprite inline per le icone.

**Aperto**

- Repo `aborruso/quarto-bootstrap-italia` da creare e pubblicare; finché non esiste, il tema si prova solo da locale.
- Bootstrap Italia 3.0.0-beta.4 esiste: aggiornamento da valutare quando esce stabile.
- Personalizzazione dei colori: richiede di ricompilare Bootstrap Italia dai sorgenti SCSS e sostituire il CSS dell'estensione.

## Comandi

```bash
./quarto/bin/quarto render     # genera _site/
./quarto/bin/quarto preview    # server locale con reload
```

Il sito va guardato via HTTP, non con `file://`.
