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
]]

local fold_di_default = false

local function vero(v)
  local s = pandoc.utils.stringify(v)
  return s == 'true' or s == '1' or s == 'show'
end

return {
  {
    Meta = function(meta)
      -- `code-fold` nel front matter o in _quarto.yml vale per tutti i blocchi
      if meta['code-fold'] ~= nil and vero(meta['code-fold']) then
        fold_di_default = true
      end
      return meta
    end,
  },
  {
    CodeBlock = function(block)
      if not quarto.doc.is_format('html:js') then
        return nil
      end
      local chiede_fold = fold_di_default
        or block.attributes['code-fold'] ~= nil
        or block.attributes['code-summary'] ~= nil
      if not chiede_fold or block.classes:includes('cell-code') then
        return nil
      end
      block.classes:insert('cell-code')
      return block
    end,
  },
}
