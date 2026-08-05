-- Bootstrap Italia per Quarto
--   1. carica il JavaScript del design system come dipendenza HTML
--      (Quarto copia il file e inserisce il tag <script> con il percorso giusto)
--   2. inserisce lo sprite delle icone all'inizio del body, così nei contenuti
--      si scrive <use href="#it-search"> senza doversi preoccupare dei percorsi
--
-- Lo sprite si disattiva con `bootstrap-italia-sprites: false` nel YAML.

local function sprites_enabled(meta)
  local v = meta['bootstrap-italia-sprites']
  if v == nil then
    return true
  end
  return pandoc.utils.stringify(v) ~= 'false'
end

local function read_file(path)
  local f = io.open(path, 'r')
  if not f then
    return nil
  end
  local content = f:read('a')
  f:close()
  return content
end

-- le tabelle di Quarto escono senza la classe .table di Bootstrap, quindi
-- senza bordi né spaziature: gliela si aggiunge qui
local function tabella(tbl)
  if not quarto.doc.is_format('html:js') then
    return nil
  end
  if not tbl.classes:includes('table') then
    tbl.classes:insert('table')
  end
  return tbl
end

return {
  {
    Table = tabella,
    Pandoc = function(doc)
      if not quarto.doc.is_format('html:js') then
        return doc
      end

      quarto.doc.add_html_dependency({
        name = 'bootstrap-italia',
        version = '2.18.3',
        scripts = {
          'bootstrap-italia/js/bootstrap-italia.bundle.min.js',
          'bootstrap-italia-search.js',
        },
      })

      -- percorso di search.json, l'indice che Quarto genera per i siti
      if quarto.project and quarto.project.offset then
        quarto.doc.include_text(
          'in-header',
          '<script>window.__BI_SEARCH_INDEX__ = "' .. quarto.project.offset .. '/search.json"</script>'
        )
      end

      if sprites_enabled(doc.meta) then
        local svg = read_file(quarto.utils.resolve_path('bootstrap-italia/svg/sprites.svg'))
        if svg then
          svg = svg:gsub('<svg', '<svg aria-hidden="true" focusable="false" style="display:none"', 1)
          quarto.doc.include_text('before-body', svg)
        else
          quarto.log.warning('Bootstrap Italia: sprites.svg non trovato, le icone non saranno disponibili')
        end
      end

      return doc
    end,
  },
}
