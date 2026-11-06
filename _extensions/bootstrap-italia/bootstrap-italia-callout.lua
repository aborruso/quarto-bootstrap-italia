--[[
  Callout di Quarto resi con il markup di Bootstrap Italia.

  Il filtro gira `at: post-quarto`: Quarto ha già costruito il callout e registrato
  i riferimenti incrociati (`@tip-uno`), e qui se ne decide solo il disegno.
]]

local VARIANTI = {
  note = { variante = 'note', icona = 'it-info-circle', titolo = 'Nota', prefisso = 'nte' },
  tip = { variante = 'success', icona = 'it-check-circle', titolo = 'Suggerimento', prefisso = 'tip' },
  warning = { variante = 'warning', icona = 'it-warning-circle', titolo = 'Attenzione', prefisso = 'wrn' },
  caution = { variante = 'important', icona = 'it-error', titolo = 'Avvertenza', prefisso = 'cau' },
  important = { variante = 'danger', icona = 'it-close-circle', titolo = 'Importante', prefisso = 'imp' },
}

local progressivo = 0
local numeri = {}

local function html_inline(titolo)
  local documento = pandoc.Pandoc({ pandoc.Plain(quarto.utils.as_inlines(titolo)) })
  return (pandoc.write(documento, 'html'):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function ha_titolo(node)
  return node.title ~= nil and pandoc.utils.stringify(node.title) ~= ''
end

-- con un id di riferimento il titolo porta l'etichetta a cui rimanda il testo:
-- «Suggerimento 1: titolo», come nel tema di Quarto
local function titolo_di(node, def)
  local id = node.attr.identifier or ''
  local proprio = ha_titolo(node) and html_inline(node.title) or nil
  if id:match('^' .. def.prefisso .. '%-') then
    numeri[def.prefisso] = (numeri[def.prefisso] or 0) + 1
    local etichetta = def.titolo .. ' ' .. numeri[def.prefisso]
    return proprio and (etichetta .. ': ' .. proprio) or etichetta
  end
  return proprio or def.titolo
end

function Callout(node)
  if not quarto.doc.is_format('html:js') then
    return nil
  end
  local def = VARIANTI[node.type]
  if not def then
    return nil
  end

  local id = node.attr.identifier or ''
  local aspetto = node.appearance
  local titolo = titolo_di(node, def)

  local classi = pandoc.List({ 'callout', def.variante })
  -- il callout senza riquadro del design system è .callout-highlight
  if aspetto == 'simple' or aspetto == 'minimal' then
    classi:insert('callout-highlight')
  end
  for _, c in ipairs(node.attr.classes or {}) do
    if not c:match('^callout') then
      classi:insert(c)
    end
  end

  local icona = (node.icon ~= false and aspetto ~= 'minimal')
    and ('<svg class="icon" aria-hidden="true"><use href="#' .. def.icona .. '"></use></svg>')
    or ''

  local apertura = pandoc.List({
    '<div class="' .. table.concat(classi, ' ') .. '"' .. (id ~= '' and (' id="' .. id .. '"') or '') .. '>',
    '<div class="callout-inner">',
    '<div class="callout-title">',
    icona,
    '<span class="text">' .. titolo .. '</span>',
    '</div>',
  })
  local chiusura = pandoc.List({ '</div>', '</div>' })

  -- richiudibile: il collapse di Bootstrap Italia, con il pulsante del design system
  local collapse = node.collapse
  if collapse ~= nil then
    progressivo = progressivo + 1
    local base = (id ~= '' and id or 'callout') .. '-' .. progressivo
    local corpo, intestazione = base .. '-corpo', base .. '-toggle'
    local aperto = collapse == false or tostring(collapse) == 'false'
    apertura:extend({
      '<div class="collapse-div">',
      '<div class="collapse-header" id="' .. intestazione .. '">',
      '<button class="callout-more-toggle" type="button" data-bs-toggle="collapse"'
        .. ' data-bs-target="#' .. corpo .. '" aria-expanded="' .. tostring(aperto) .. '"'
        .. ' aria-controls="' .. corpo .. '">Leggi di più<span aria-hidden="true"></span></button>',
      '</div>',
      '<div id="' .. corpo .. '" class="collapse' .. (aperto and ' show' or '') .. '"'
        .. ' role="region" aria-labelledby="' .. intestazione .. '">',
      '<div class="collapse-body">',
    })
    chiusura = pandoc.List({ '</div>', '</div>', '</div>', '</div>', '</div>' })
  end

  local risultato = pandoc.Blocks({ pandoc.RawBlock('html', table.concat(apertura, '\n')) })
  risultato:extend(quarto.utils.as_blocks(node.content))
  risultato:insert(pandoc.RawBlock('html', table.concat(chiusura, '\n')))
  return risultato
end
