-- Intestazione, menu e piè di pagina di Bootstrap Italia, generati dalla
-- configurazione del sito. Chi usa il tema scrive solo YAML:
--   website.navbar       le voci del menu, con la sintassi standard di Quarto
--   website.page-footer  i link in fondo alla pagina (`center`)
--   bootstrap-italia     ciò che Quarto non prevede: ente, lingue, colonne del footer
--
-- `website` non arriva ai filtri, perciò si legge da _quarto.yml. La conseguenza è
-- che non vede i profili né `metadata-files`; `bootstrap-italia` invece passa dai
-- metadati del documento, e quelli li rispetta.
--
-- Vale solo per i siti: un documento singolo non ha né menu né altre pagine.

local stringify = pandoc.utils.stringify
local tipo = pandoc.utils.type

local function esc(testo)
  return (stringify(testo or ''):gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

local function leggi(percorso)
  local f = io.open(percorso, 'r')
  if not f then
    return nil
  end
  local testo = f:read('a')
  f:close()
  return testo
end

-- il blocco YAML di un file, letto come metadati. Senza `smart`, che
-- trasformerebbe i `--` degli indirizzi in trattini lunghi.
local function metadati(yaml)
  return pandoc.read('---\n' .. yaml .. '\n---\n', 'markdown-smart').meta
end

local function configurazione_sito(cartella)
  local yaml = leggi(cartella .. '/_quarto.yml') or leggi(cartella .. '/_quarto.yaml')
  return yaml and metadati(yaml) or nil
end

local function normalizza(percorso)
  return (percorso:gsub('^%./', ''):gsub('^/', ''))
end

local function e_esterno(href)
  return href == '' or href:sub(1, 1) == '#' or href:match('^%a[%w+.-]*:') ~= nil
end

-- un sorgente del progetto diventa il percorso della pagina generata, relativo
-- alla pagina corrente
local function collegamento(href)
  href = stringify(href or '')
  if e_esterno(href) then
    return href == '' and '#' or href
  end
  local percorso, ancora = href:match('^([^#]*)(.*)$')
  percorso = normalizza(percorso):gsub('%.qmd$', '.html'):gsub('%.ipynb$', '.html'):gsub('%.md$', '.html')
  return quarto.project.offset .. '/' .. percorso .. ancora
end

-- una voce si può scrivere `- pagina.qmd` o senza `text`: come in Quarto, il testo
-- è allora il titolo della pagina
local function titolo_pagina(cartella, href)
  local testo = leggi(cartella .. '/' .. normalizza(href))
  local yaml = testo and testo:match('^%-%-%-\n(.-)\n%-%-%-')
  return yaml and stringify(metadati(yaml).title or '') or ''
end

local function voci(elenco, cartella)
  local risultato = {}
  if tipo(elenco) ~= 'List' then
    return risultato
  end
  for _, voce in ipairs(elenco) do
    if tipo(voce) == 'Inlines' then
      voce = { href = voce }
    end
    local sottomenu = voce.menu and voci(voce.menu, cartella) or nil
    local href = stringify(voce.href or '')
    local testo = stringify(voce.text or '')
    if testo == '' and href ~= '' and not e_esterno(href) then
      testo = titolo_pagina(cartella, href)
    end
    table.insert(risultato, { testo = testo, href = href, menu = sottomenu })
  end
  return risultato
end

local function icona(nome, classi)
  return '<svg class="' .. classi .. '" aria-hidden="true"><use href="#' .. nome .. '"></use></svg>'
end

local function html_di(valore)
  if tipo(valore) == 'Inlines' then
    valore = pandoc.Blocks({ pandoc.Plain(valore) })
  end
  return pandoc.write(pandoc.Pandoc(valore), 'html')
end

local function selettore_lingua(lingue, lingua_pagina)
  if tipo(lingue) ~= 'List' or #lingue == 0 then
    return ''
  end
  local corrente = lingue[1]
  for _, l in ipairs(lingue) do
    if stringify(l.lang or '') == lingua_pagina then
      corrente = l
    end
  end
  local righe = {}
  for _, l in ipairs(lingue) do
    local scelta = l == corrente and ' <span class="visually-hidden">selezionata</span>' or ''
    table.insert(righe, '<li><a class="dropdown-item list-item" href="' .. esc(collegamento(l.href))
      .. '" hreflang="' .. esc(l.lang) .. '"><span>' .. esc(l.text) .. scelta .. '</span></a></li>')
  end
  return [[
<div class="it-header-slim-right-zone">
<div class="nav-item dropdown">
<a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
<span class="visually-hidden">Selezione lingua: lingua selezionata</span>
<span>]] .. esc(corrente.text) .. [[</span>
]] .. icona('it-expand', 'icon d-none d-lg-block') .. [[
</a>
<div class="dropdown-menu"><div class="row"><div class="col-12"><div class="link-list-wrapper">
<ul class="link-list">]] .. table.concat(righe) .. [[</ul>
</div></div></div></div>
</div>
</div>]]
end

local function barra_ente(tema, lingua_pagina)
  local ente = tema.ente
  local selettore = selettore_lingua(tema.lingue, lingua_pagina)
  if not ente and selettore == '' then
    return ''
  end
  local nome = ''
  if ente then
    local e_mappa = tipo(ente) == 'table'
    local testo = e_mappa and ente.text or ente
    local href = e_mappa and ente.href or nil
    nome = '<a class="d-none d-lg-block navbar-brand" href="' .. esc(collegamento(href)) .. '">' .. esc(testo) .. '</a>'
  end
  return [[
<div class="it-header-slim-wrapper"><div class="container"><div class="row"><div class="col-12">
<div class="it-header-slim-wrapper-content">
]] .. nome .. selettore .. [[
</div>
</div></div></div></div>]]
end

-- `logo` è il nome di un'icona del design system o il percorso di un'immagine
local function logo(tema)
  local valore = stringify(tema.logo or 'it-pa')
  if valore:match('^it%-[%w-]+$') then
    return icona(valore, 'icon')
  end
  return '<img class="icon" src="' .. esc(collegamento(valore)) .. '" alt="">'
end

local function ricerca(sito)
  if sito.search == false then
    return ''
  end
  return [[
<div class="it-right-zone"><div class="it-search-wrapper">
<span class="d-none d-md-block">Cerca</span>
<a class="search-link rounded-icon" aria-label="Cerca nel sito" href="#" data-bi-search>]]
    .. icona('it-search', 'icon') .. [[</a>
</div></div>]]
end

local function e_pagina(voce, pagina)
  return voce.href ~= '' and not e_esterno(voce.href)
    and normalizza(voce.href:match('^[^#]*')) == pagina
end

local function voce_menu(voce, pagina, indice)
  if voce.menu then
    local righe, aperta = {}, false
    for _, sotto in ipairs(voce.menu) do
      local attiva = e_pagina(sotto, pagina)
      aperta = aperta or attiva
      table.insert(righe, '<li><a class="dropdown-item list-item' .. (attiva and ' active' or '')
        .. '" href="' .. esc(collegamento(sotto.href)) .. '"' .. (attiva and ' aria-current="page"' or '')
        .. '><span>' .. esc(sotto.testo) .. '</span></a></li>')
    end
    local id = 'nav-menu-' .. indice
    return '<li class="nav-item dropdown' .. (aperta and ' active' or '') .. '">'
      .. '<a class="nav-link dropdown-toggle' .. (aperta and ' active' or '')
      .. '" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false" id="' .. id .. '">'
      .. '<span>' .. esc(voce.testo) .. '</span>' .. icona('it-expand', 'icon icon-xs') .. '</a>'
      .. '<div class="dropdown-menu" role="region" aria-labelledby="' .. id .. '"><div class="link-list-wrapper">'
      .. '<ul class="link-list">' .. table.concat(righe) .. '</ul></div></div></li>'
  end
  local attiva = e_pagina(voce, pagina)
  return '<li class="nav-item' .. (attiva and ' active' or '') .. '"><a class="nav-link' .. (attiva and ' active' or '')
    .. '" href="' .. esc(collegamento(voce.href)) .. '"' .. (attiva and ' aria-current="page"' or '')
    .. '><span>' .. esc(voce.testo) .. '</span></a></li>'
end

local function menu(elenco, pagina)
  if #elenco == 0 then
    return ''
  end
  local righe = {}
  for i, voce in ipairs(elenco) do
    table.insert(righe, voce_menu(voce, pagina, i))
  end
  return [[
<div class="it-header-navbar-wrapper"><div class="container"><div class="row"><div class="col-12">
<nav class="navbar navbar-expand-lg" aria-label="Navigazione principale">
<button class="custom-navbar-toggler" type="button" aria-controls="nav-principale" aria-expanded="false" aria-label="Mostra/Nascondi la navigazione" data-bs-toggle="navbarcollapsible" data-bs-target="#nav-principale">]]
    .. icona('it-burger', 'icon bg-override') .. [[</button>
<div class="navbar-collapsable" id="nav-principale" style="display: none;">
<div class="overlay" style="display: none;"></div>
<div class="close-div"><button class="btn close-menu" type="button"><span class="visually-hidden">Nascondi la navigazione</span>]]
    .. icona('it-close-big', 'icon') .. [[</button></div>
<div class="menu-wrapper"><ul class="navbar-nav">]] .. table.concat(righe) .. [[</ul></div>
</div>
</nav>
</div></div></div></div>]]
end

local function intestazione(sito, tema, lingua_pagina, voci_menu, pagina, nome, sottotitolo)
  return [[
<div class="skiplinks">
<a class="visually-hidden-focusable" href="#main-content">Vai al contenuto principale</a>
<a class="visually-hidden-focusable" href="#it-footer">Vai al footer</a>
</div>
<header class="it-header-wrapper">
]] .. barra_ente(tema, lingua_pagina) .. [[
<div class="it-nav-wrapper">
<div class="it-header-center-wrapper"><div class="container"><div class="row"><div class="col-12">
<div class="it-header-center-content-wrapper">
<div class="it-brand-wrapper"><a href="]] .. esc(collegamento('index.qmd')) .. [[">
]] .. logo(tema) .. [[
<div class="it-brand-text"><div class="it-brand-title">]] .. esc(nome) .. [[</div>]]
    .. (sottotitolo ~= '' and '<div class="it-brand-tagline d-none d-md-block">' .. esc(sottotitolo) .. '</div>' or '') .. [[
</div>
</a></div>
]] .. ricerca(sito) .. [[
</div>
</div></div></div></div>
]] .. menu(voci_menu, pagina) .. [[
</div>
</header>
<div id="quarto-content">
<main id="main-content" class="content container my-5">]]
end

local function colonna(c, larghezza)
  local titolo = esc(c.title)
  local testa = c.href
      and '<h4><a href="' .. esc(collegamento(c.href)) .. '" title="Vai alla pagina: ' .. titolo .. '">' .. titolo .. '</a></h4>'
      or '<h4>' .. titolo .. '</h4>'
  local corpo = {}
  if c.text then
    table.insert(corpo, html_di(c.text))
  end
  if tipo(c.links) == 'List' then
    local righe = {}
    for _, l in ipairs(c.links) do
      table.insert(righe, '<li><a class="list-item" href="' .. esc(collegamento(l.href)) .. '">' .. esc(l.text) .. '</a></li>')
    end
    table.insert(corpo, '<div class="link-list-wrapper"><ul class="footer-list link-list clearfix">' .. table.concat(righe) .. '</ul></div>')
  end
  if tipo(c.social) == 'List' then
    local righe = {}
    for _, l in ipairs(c.social) do
      table.insert(righe, '<li class="list-inline-item"><a class="p-2 text-white" href="' .. esc(collegamento(l.href))
        .. '" target="_blank" rel="noopener noreferrer">' .. icona(stringify(l.icon), 'icon icon-sm icon-white align-top')
        .. '<span class="visually-hidden">' .. esc(l.text) .. '</span></a></li>')
    end
    table.insert(corpo, '<ul class="list-inline text-left social">' .. table.concat(righe) .. '</ul>')
  end
  return '<div class="col-lg-' .. larghezza .. ' col-md-' .. larghezza .. ' pb-2">' .. testa .. table.concat(corpo) .. '</div>'
end

local function piede(sito, tema, nome, sottotitolo, cartella)
  local colonne = {}
  if tipo(tema.footer) == 'List' and #tema.footer > 0 then
    local larghezza = math.max(3, math.floor(12 / #tema.footer))
    for _, c in ipairs(tema.footer) do
      table.insert(colonne, colonna(c, larghezza))
    end
  end
  local sezione_colonne = #colonne > 0
      and '<section class="py-4 border-white border-top"><div class="row">' .. table.concat(colonne) .. '</div></section>'
      or ''

  local legali = {}
  local page_footer = sito['page-footer']
  if tipo(page_footer) == 'table' then
    for _, voce in ipairs(voci(page_footer.center, cartella)) do
      table.insert(legali, '<li class="list-inline-item"><a href="' .. esc(collegamento(voce.href))
        .. '" title="' .. esc(voce.testo) .. '">' .. esc(voce.testo) .. '</a></li>')
    end
  end
  local sezione_legali = #legali > 0
      and '<div class="it-footer-small-prints clearfix"><div class="container">'
        .. '<h3 class="visually-hidden">Sezione link utili</h3>'
        .. '<ul class="it-footer-small-prints-list list-inline mb-0 d-flex flex-column flex-md-row">'
        .. table.concat(legali) .. '</ul></div></div>'
      or ''

  return [[
</main>
</div>
<footer class="it-footer" id="it-footer">
<div class="it-footer-main"><div class="container">
<section><div class="row clearfix"><div class="col-sm-12">
<div class="it-brand-wrapper"><a href="]] .. esc(collegamento('index.qmd')) .. [[">
]] .. logo(tema) .. [[
<div class="it-brand-text"><h2 class="no_toc">]] .. esc(nome) .. [[</h2>]]
    .. (sottotitolo ~= '' and '<h3 class="no_toc d-none d-md-block">' .. esc(sottotitolo) .. '</h3>' or '') .. [[
</div>
</a></div>
</div></div></section>
]] .. sezione_colonne .. [[
</div></div>
]] .. sezione_legali .. [[
</footer>]]
end

return {
  {
    Pandoc = function(doc)
      if not quarto.doc.is_format('html:js') then
        return doc
      end
      local cartella = quarto.project and quarto.project.directory
      local conf = cartella and configurazione_sito(cartella)
      local sito = conf and conf.website
      if tipo(sito) ~= 'table' then
        return doc
      end

      local tema = doc.meta['bootstrap-italia']
      if tipo(tema) ~= 'table' then
        tema = {}
      end
      local nome = stringify(tema.istituzione or sito.title or doc.meta.title or '')
      local sottotitolo = stringify(tema.tagline or '')
      local pagina = quarto.doc.input_file:sub(#cartella + 2)
      local lingua = stringify(doc.meta.lang or '')

      local navbar = tipo(sito.navbar) == 'table' and sito.navbar or {}
      local voci_menu = voci(navbar.left, cartella)
      for _, voce in ipairs(voci(navbar.right, cartella)) do
        table.insert(voci_menu, voce)
      end

      quarto.doc.include_text('before-body', intestazione(sito, tema, lingua, voci_menu, pagina, nome, sottotitolo))
      quarto.doc.include_text('after-body', piede(sito, tema, nome, sottotitolo, cartella))
      return doc
    end,
  },
}
