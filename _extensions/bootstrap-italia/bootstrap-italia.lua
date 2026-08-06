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

-- Nei div fenced Pandoc avvolge il contenuto in un paragrafo. In alcuni
-- componenti del design system — contenitori flex, che contano sui figli
-- diretti — quel <p> prende il posto dell'elemento vero e ne rompe
-- l'allineamento: `::: {.chip .chip-simple}` uscirebbe con l'etichetta fuori
-- dal chip. Qui il paragrafo viene tolto, così l'HTML è quello del design
-- system e lo stile ufficiale si applica senza correzioni.
local SENZA_PARAGRAFO = { 'chip', 'callout-title', 'card-teaser', 'btn-group' }

local function ha_classe(div, elenco)
  for _, classe in ipairs(elenco) do
    if div.classes:includes(classe) then
      return true
    end
  end
  return false
end

local function senza_paragrafo(div)
  div.content = div.content:map(function(blocco)
    if blocco.t ~= 'Para' then
      return blocco
    end
    return pandoc.Plain(blocco.content)
  end)
  return div
end

-- Nelle card il titolo del design system è `<h3 class="card-title h5">`: chi
-- scrive mette un normale titolo Markdown e le classi le aggiunge il tema.
-- Il titolo diventa HTML grezzo di proposito: aggiungere le classi all'header
-- le farebbe finire anche sulla <section> che Quarto costruisce intorno,
-- e `.card-title.h5` sulla sezione cambierebbe il corpo del testo.
local function card(div)
  div.content = div.content:walk({
    Header = function(h)
      local testo = pandoc.write(pandoc.Pandoc({ pandoc.Plain(h.content) }), 'html')
      testo = testo:gsub('^%s+', ''):gsub('%s+$', '')
      local tag = 'h' .. h.level
      return pandoc.RawBlock(
        'html',
        '<' .. tag .. ' class="card-title h5">' .. testo .. '</' .. tag .. '>'
      )
    end,
  })
  return div
end

-- `[Leggi di più](#){.read-more}`: il design system vuole il testo del link
-- dentro uno <span class="text">, che qui viene aggiunto da sé.
local function read_more(link)
  if not link.classes:includes('read-more') then
    return nil
  end
  if #link.content == 1 and link.content[1].t == 'Span' and link.content[1].classes:includes('text') then
    return nil
  end
  link.content = pandoc.List({ pandoc.Span(link.content, pandoc.Attr('', { 'text' })) })
  return link
end

local function componenti(div)
  if not quarto.doc.is_format('html:js') then
    return nil
  end
  if ha_classe(div, SENZA_PARAGRAFO) then
    div = senza_paragrafo(div)
  end
  if div.classes:includes('card-body') then
    div = card(div)
  end
  return div
end

return {
  {
    Div = componenti,
    Link = read_more,
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
