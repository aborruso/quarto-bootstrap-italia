---
title: "Bootstrap Italia per Quarto — documento di prodotto"
versione: 0.1.0
data: 2026-08-05
---

# Bootstrap Italia per Quarto

## Il problema

Una pubblica amministrazione che deve pubblicare un sito o un documento web è tenuta a rispettare le Linee guida di design per i siti internet e i servizi digitali della PA (art. 53 del CAD), che rimandano al design system `.italia` e al framework Bootstrap Italia.

Quarto è lo strumento con cui in quel contesto si scrivono già molti contenuti — analisi, rapporti, documentazione tecnica, siti di progetto — perché parte da Markdown e produce HTML, PDF e slide dagli stessi sorgenti. Ma Quarto arriva con Bootstrap e 25 temi Bootswatch: nessuno dei quali è conforme al design system italiano.

Oggi chi vuole entrambe le cose deve mettere in piedi a mano un impianto fragile: disattivare il tema di Quarto, scaricare Bootstrap Italia, capire da dove arrivano i font, come si caricano le icone, perché i callout si rompono, dove finiscono gli asset nell'output. È un lavoro di giorni che ogni ente rifà da capo, e che si rompe al primo aggiornamento.

## L'obiettivo

**Chi scrive deve ottenere Bootstrap Italia usando Quarto nel modo più standard possibile.**

Nessuna procedura speciale, nessun impianto da ricostruire, nessun linguaggio nuovo da imparare: si installa come si installa qualunque estensione di Quarto, si scrive il Markdown che si scriverebbe comunque, e il risultato è conforme al design system.

Questo si traduce in tre requisiti non negoziabili.

### 1. Installazione standard

```bash
quarto add aborruso/quarto-bootstrap-italia
```

È il comando con cui si installa qualunque estensione di Quarto. Non serve scaricare Bootstrap Italia a parte, né npm, né una pipeline di build: l'estensione porta con sé CSS, JavaScript, font e icone, e funziona senza rete.

Per partire da un sito già impostato:

```bash
quarto use template aborruso/quarto-bootstrap-italia
```

### 2. Uso standard

Nel documento si dichiara il formato, come si fa con qualunque altro:

```yaml
format:
  bootstrap-italia-html: default
```

Da lì in poi si scrive Quarto normale. La sintassi standard deve produrre componenti del design system, non richiedere di scrivere HTML a mano:

| Si scrive | Si ottiene |
| --- | --- |
| `::: {.callout-warning}` | il callout di Bootstrap Italia, con icona e variante corrette |
| una tabella Markdown | la tabella del design system |
| `![didascalia](img.png)` | la figura con la didascalia del design system |
| `::: {.panel-tabset}` | le schede del design system |
| `toc: true` | l'indice della pagina, nello stile del design system |
| un blocco di codice | il blocco di codice del design system |

Chi vuole spingersi oltre usa direttamente le classi di Bootstrap Italia nei div fenced di Quarto (`::: {.card-wrapper}`) o in HTML: è un'aggiunta, non un obbligo.

Il documento resta portabile: se lo si rende con `format: html`, esce un normale documento Quarto. Nessun contenuto viene scritto in un dialetto che funziona solo con questo tema.

### 3. Conformità verificabile

Il tema non deve limitarsi ad "assomigliare" a Bootstrap Italia: deve usarne il CSS ufficiale, i font ufficiali e le icone ufficiali, alla versione stabile dichiarata. Ogni tipo di contenuto che Quarto sa produrre deve essere verificato: la pagina `demo.qmd` esiste per questo, ed è il banco di prova da rieseguire a ogni aggiornamento.

## Chi lo usa

- **Un ente pubblico** che pubblica un sito istituzionale, una documentazione tecnica o un rapporto e deve rispettare le linee guida di design.
- **Un fornitore della PA** che deve consegnare qualcosa di conforme senza costruirsi un tema da zero a ogni commessa.
- **Chi lavora con i dati pubblici** — analisi, cruscotti, rapporti — e vuole che il risultato abbia l'aspetto istituzionale che gli compete.

Il profilo comune: sa scrivere Markdown, non necessariamente SCSS o JavaScript. Se per avere un callout conforme deve scrivere quattro div annidati, il tema ha fallito il suo scopo.

## Cosa c'è dentro

| Risorsa | Come arriva nella pagina |
| --- | --- |
| `bootstrap-italia.min.css` 2.18.3 | opzione `css` del formato |
| Font Titillium Web, Lora, Roboto Mono | `fonts.css`, `@font-face` statiche |
| JavaScript del design system | dipendenza HTML dichiarata dal filtro Lua |
| Sprite delle 179 icone | inserito nel body dal filtro Lua |
| Ricerca full text | `bootstrap-italia-search.js` sull'indice `search.json` di Quarto |
| Callout di Quarto → callout del design system | filtro Lua `at: pre-ast` |
| Classe `.table` sulle tabelle | filtro Lua |
| Raccordo per indice, codice, schede, didascalie | `quarto-bootstrap-italia.css` |
| Formule in MathML, senza librerie esterne | `html-math-method: mathml` |

## Cosa resta fuori

- **Personalizzazione via SCSS.** Quarto compila SCSS solo attraverso l'opzione `theme`, che reintrodurrebbe il suo Bootstrap sopra a quello di Bootstrap Italia. Chi deve cambiare i colori istituzionali ricompila Bootstrap Italia dai suoi sorgenti e sostituisce il CSS dell'estensione.
- **Formati diversi da HTML.** PDF e slide restano quelli di Quarto: il design system è un sistema per il web.
- **Modelli di sito verticali** (Comuni, Scuole, ASL, Musei civici). Il tema porta il design system, non l'architettura dell'informazione di quei modelli.
- **La ricerca di Quarto.** La sua interfaccia è legata al tema Bootstrap di Quarto e non è recuperabile con `theme: none`: l'estensione ne fornisce una propria sullo stesso indice.

## Come si misura se funziona

1. Un utente che non ha mai visto il tema passa da zero a un sito conforme con due comandi e nessuna modifica manuale agli asset.
2. Un documento Quarto esistente, cambiando solo il formato in `bootstrap-italia-html`, viene reso in modo coerente: nessun contenuto perde stile.
3. `demo.qmd` — che raccoglie tutti i tipi di contenuto di Quarto — non mostra elementi privi di stile.
4. L'aggiornamento a una nuova versione di Bootstrap Italia consiste nel sostituire la cartella `bootstrap-italia/` e rigenerare `fonts.css`.

## Stato

Versione 0.1.0, funzionante e verificata in locale. Da fare: pubblicazione del repository, verifica di `quarto add` e `quarto use template` dal remoto, valutazione di Bootstrap Italia 3.x quando uscirà stabile.
