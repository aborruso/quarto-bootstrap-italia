--[[
  Codice richiudibile (code-fold) sui blocchi di codice scritti a mano.

  Quarto applica `code-fold`/`code-summary` solo ai blocchi che hanno la classe
  `cell-code`, cioè alle celle eseguibili prodotte da knitr o jupyter. In un sito
  fatto di soli .qmd statici il blocco

      ```{.python code-fold="true" code-summary="Mostra il codice"}

  uscirebbe quindi sempre aperto. Questo filtro aggiunge `cell-code` ai blocchi
  che chiedono il fold, così la sintassi documentata da Quarto funziona senza che
  chi scrive debba conoscere la classe interna.

  Gira `at: pre-ast`, prima del filtro di Quarto che trasforma il blocco in
  <details>.

  Nota: il fold va chiesto blocco per blocco. `code-fold: true` nel front matter
  è un'opzione di formato e non è leggibile dai filtri delle estensioni (non
  arriva né in `meta` né in `param`), quindi non ha effetto sui blocchi statici.
]]

return {
  {
    CodeBlock = function(block)
      if not quarto.doc.is_format('html:js') then
        return nil
      end
      local chiede_fold = block.attributes['code-fold'] ~= nil
        or block.attributes['code-summary'] ~= nil
      if not chiede_fold or block.classes:includes('cell-code') then
        return nil
      end
      block.classes:insert('cell-code')
      return block
    end,
  },
}
