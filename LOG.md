# Log

## 2026-08-06

- `code-fold` non funzionava sui blocchi di codice scritti a mano: Quarto lo applica solo ai blocchi con classe `cell-code`, cioè alle celle eseguibili. Nuovo filtro `bootstrap-italia-code.lua` (`at: pre-ast`) che aggiunge quella classe ai blocchi che chiedono il fold, così nel Markdown si scrive solo la sintassi documentata; CSS per il `<summary>`, che senza il tema di Quarto usciva senza stile
- Verificato che `code-fold: true` nel front matter **non** è raggiungibile dai filtri delle estensioni (non arriva né in `meta` né in `param`, a nessuna fase): il fold va chiesto blocco per blocco. Il riepilogo predefinito è invece già in italiano ("Codice"), tradotto da `lang: it`
- Callout: il filtro consumava solo `title` e ignorava in silenzio gli altri tre attributi che Quarto documenta. Ora `collapse` produce il callout richiudibile nativo del design system (`collapse-div` + `callout-more-toggle`, con il collapse di Bootstrap già caricato), `icon=false` toglie l'icona, `appearance="simple"|"minimal"` usa `callout-highlight` — con il bordo di `callout-inner` annullato, altrimenti restava un riquadro dentro la barra laterale
- Colmati i vuoti di stile che restavano dal `theme: none`: il pulsante "copia" era senza icona (il font bootstrap-icons di Quarto non c'è più) e ora usa le icone del design system in maschera; stile per il nome file (`filename=`) e per le annotazioni di codice, spostando il pulsante di copia dove non le copre
- `demo.qmd` copre i casi nuovi: fold, `filename=`, annotazioni, callout richiudibile, senza riquadro e senza icona. Controllo axe WCAG 2.1 AA sulla demo: nessuna violazione

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
