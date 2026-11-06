# Log

## 2026-11-06

- Quarto del progetto e CI passati da 1.10.18 a 1.10.20. Confronto del sito reso con le due versioni: HTML uguale salvo `generator` e hash del CSS di evidenziazione. axe-core sulle pagine: nessuna violazione. Nuovo avviso al render: `variable used before declaration`, variabile `link-color`
- `eventi.qmd`: nelle card i `###` restavano visibili, perché senza righe vuote firma, titolo e testo finivano in un solo paragrafo. Il difetto c'era anche con la 1.10.18
- Intestazione, menu e piè di pagina non sono più partial scritti a mano: li genera `bootstrap-italia-chrome.lua` da `_quarto.yml`. Il menu è il `website.navbar` standard, letto dal file perché `website` non arriva ai filtri; il resto sta sotto `bootstrap-italia:`. La voce attiva è calcolata al render, senza JavaScript. Tolto «Accedi», lingue configurabili, nessuna intestazione sui documenti singoli
- Notizie impostate sul modello Comuni con funzioni native: griglia `listing: type: grid`, `categories`, `image`, figure e citazioni in Markdown. Testi di esempio realistici su tutte le pagine, sei notizie con immagini generate. Figure e citazioni usano ora le regole di Bootstrap Italia, tolta la nostra regola su `blockquote`
- Preparata la versione 0.2.0: `CHANGELOG.md`, `quarto-required: >=1.10.18`
- Lo starter ora è nella radice del repository, con l'estensione, e il sito dimostrativo in `_demo/`: `quarto use template` copia solo un sito essenziale con un solo comando, senza duplicare il tema. Una sottocartella `template/` non avrebbe portato l'estensione, provato sul repository pubblico. `_demo/_extensions` è un collegamento simbolico. La CI installa e rende lo starter a ogni push
- Palette: le classi `.bg-*`, `.text-*`, `.border-*` usavano `--bs-*-rgb`, terne fisse scollegate da `--bi-*`, e non cambiavano con la palette dell'ente: ora derivano dai token. Nel CSS del tema colori fissi e `--bs-…` sono passati a `--bi-…`, con le nuove `--bi-surface`, `--bi-surface-dark`, `--bi-caption`; `scripts/controlla-colori.py` in CI segnala quelli nuovi
- Riferimenti ai callout risolti (issue #3): il filtro non riscrive più il div a `pre-ast`, ma usa a `post-quarto` il gestore pubblico `Callout`, dopo la registrazione dei riferimenti. I titoli conservano la formattazione e valgono le opzioni di Quarto come `callout-appearance`
- Verificato il codice eseguito con knitr e Jupyter (issue #2): corretti immagini Jupyter non adattabili, tabelle con didascalia centrate, tabelle larghe non raggiungibili da tastiera, contrasto degli errori e di `paged_table`; avvisi ed errori ora si distinguono. Nuove pagine `dati-python.qmd` e `dati-r.qmd` con `freeze: auto`: la CI le rende da `_freeze/` senza motori. `quarto.metadata.get('website')` non restituisce nulla: la lettura di `_quarto.yml` resta necessaria
- Provata l'installazione dal repository pubblico (issue #1): `quarto add` e `quarto use template` funzionano. Il template non copia più `LOG.md`, `package.json` e `scripts/`. Quarto locale spostato da `./quarto` a `_quarto-bin/`: il prefisso `_` lo esclude dal render, e in `_quarto.yml` resta solo `render: "*.qmd"`, che tiene `LOG.md`, `docs/` e `tasks/` fuori dal sito
- Valutata l'estensione `mcanouil/quarto-highlight-text`: la 2.4.0 funziona col tema anche in callout, card, chip e tabelle; la 3.0.0 richiede Quarto >=1.10.19. Non adottata: per i colori bastano le classi del design system

## 2026-08-06

- `code-fold` non funzionava sui blocchi di codice scritti a mano: Quarto lo applica solo ai blocchi con classe `cell-code`, cioè alle celle eseguibili. Nuovo filtro `bootstrap-italia-code.lua` (`at: pre-ast`) che aggiunge quella classe ai blocchi che chiedono il fold, così nel Markdown si scrive solo la sintassi documentata; CSS per il `<summary>`, che senza il tema di Quarto usciva senza stile
- Verificato che `code-fold: true` nel front matter **non** è raggiungibile dai filtri delle estensioni (non arriva né in `meta` né in `param`, a nessuna fase): il fold va chiesto blocco per blocco. Il riepilogo predefinito è invece già in italiano ("Codice"), tradotto da `lang: it`
- Callout: il filtro consumava solo `title` e ignorava in silenzio gli altri tre attributi che Quarto documenta. Ora `collapse` produce il callout richiudibile nativo del design system (`collapse-div` + `callout-more-toggle`, con il collapse di Bootstrap già caricato), `icon=false` toglie l'icona, `appearance="simple"|"minimal"` usa `callout-highlight` — con il bordo di `callout-inner` annullato, altrimenti restava un riquadro dentro la barra laterale
- Colmati i vuoti di stile che restavano dal `theme: none`: il pulsante "copia" era senza icona (il font bootstrap-icons di Quarto non c'è più) e ora usa le icone del design system in maschera; stile per il nome file (`filename=`) e per le annotazioni di codice, spostando il pulsante di copia dove non le copre
- `demo.qmd` copre i casi nuovi: fold, `filename=`, annotazioni, callout richiudibile, senza riquadro e senza icona. Controllo axe WCAG 2.1 AA sulla demo: nessuna violazione
- Ripulito l'HTML grezzo dai contenuti: card, bottoni, chip, badge, barra di avanzamento e icone si scrivono ora con la sintassi di Quarto in tutte le pagine. Quello che il Markdown non sa esprimere lo costruisce il tema:
  - shortcode `{{< icona it-file primary >}}` (nuovo `bootstrap-italia-shortcodes.lua`), con `alt=` per le icone che portano significato
  - il titolo dentro `::: {.card-body}` diventa `<h3 class="card-title h5">`; le classi non vengono aggiunte all'header perché finirebbero anche sulla `<section>` che Quarto costruisce intorno, cambiando il corpo del testo
  - `[Leggi di più](#){.read-more}` prende da sé lo `<span class="text">` che il design system richiede
  - nei componenti flex (chip, btn-group, card-teaser, callout-title) sparisce il paragrafo che Pandoc mette intorno al contenuto dei div fenced: era lui a spingere l'etichetta fuori dal chip
- Il filtro `bootstrap-italia.lua` è passato a `at: post-quarto`: prima gli shortcode sono ancora segnaposto e il markup non è quello definitivo
- Trovato invece un caso che resta rotto e non è un ritocco: i riferimenti incrociati ai callout (`@tip-uno` → `?@tip-uno`), perché il filtro riscrive il callout in HTML grezzo prima che i crossref di Quarto lo vedano. Tracciato come issue [#3](https://github.com/aborruso/quarto-bootstrap-italia/issues/3)

## 2026-08-05

- Primo impianto del formato Quarto `bootstrap-italia-html`: `theme: none` e Bootstrap Italia 2.18.3 al posto del Bootstrap di Quarto
- Font portati da JavaScript (`loadFonts()`) a `@font-face` statiche in `fonts.css`
- Estensione riorganizzata per l'installazione con `quarto add`; starter con header e footer istituzionali
- Icone: sprite inserito nella pagina dal filtro Lua, si usa `<use href="#it-nome">` senza percorsi
- Ricerca full text sull'indice `search.json` di Quarto, con i componenti del design system
- Callout scritti in Markdown standard e riscritti dal filtro `at: pre-ast`
- `demo.qmd` come banco di prova dei tipi di contenuto; da lì sono emersi e sono stati risolti: tabelle senza `.table`, codice senza box, schede e indice senza stile, didascalie centrate, formule non convertite
- Listing: erano appesi al `body`, ora dentro `main` con il proprio stile
- Accessibilità: nessuna violazione WCAG 2.1 AA con il report `axe` integrato in Quarto 1.10; corretti focus di ritorno della ricerca, landmark dell'header, `fig-alt` e gerarchia dei titoli
- Numeri di riga nel codice: annullato il posizionamento negativo di Pandoc, che li portava fuori dal riquadro
- CI con render, controlli di regressione sull'output, controllo di accessibilità e pubblicazione su GitHub Pages
