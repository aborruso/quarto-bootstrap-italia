# Changelog

## 0.2.0

Richiede Quarto 1.10.18 o successivo. Verificato su 1.10.18 e 1.10.20.

### Cambiamenti da adeguare

- Intestazione, menu e piè di pagina si configurano in `_quarto.yml` (`website.navbar`, `website.page-footer`, `bootstrap-italia:`). I partial e `include-before-body` / `include-after-body` vanno tolti, altrimenti l'intestazione compare due volte
- Tolto «Accedi» dall'intestazione

### Novità

- Riferimenti ai callout: `@tip-uno` diventa «Suggerimento 1», nella stessa pagina
- Selettore di lingua configurabile, logo come icona o immagine
- Notizie con `listing: type: grid`, categorie e immagini negli stili del design system
- Output di knitr e Jupyter allineato al design system: immagini adattabili, tabelle larghe raggiungibili da tastiera, avvisi ed errori distinti
- Tutti i colori del tema e le classi `.bg-*`, `.text-*`, `.border-*` seguono la palette; nuove variabili `--bi-surface`, `--bi-surface-dark`, `--bi-caption`
- `quarto use template` copia uno starter essenziale invece del sito dimostrativo, che è in `_demo/`

## 0.1.0

Prima versione: formato `bootstrap-italia-html`, ricerca, callout, icone.
