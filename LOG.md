# Log

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
