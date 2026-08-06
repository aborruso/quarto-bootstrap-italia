--[[
  Callout di Quarto resi con il markup di Bootstrap Italia.

  Nel Markdown si scrive la sintassi standard di Quarto:

      ::: {.callout-warning}
      ## Titolo
      Testo del callout.
      :::

  e in output esce un callout del design system:

      <div class="callout warning">
        <div class="callout-inner">
          <div class="callout-title">…</div>
          …
        </div>
      </div>

  Il filtro gira `at: pre-ast`, cioè prima dei filtri di Quarto: senza il suo
  tema Bootstrap, Quarto degraderebbe i callout a blockquote.
]]

local VARIANTI = {
  ['callout-note'] = { variante = 'note', icona = 'it-info-circle', titolo = 'Nota' },
  ['callout-tip'] = { variante = 'success', icona = 'it-check-circle', titolo = 'Suggerimento' },
  ['callout-warning'] = { variante = 'warning', icona = 'it-warning-circle', titolo = 'Attenzione' },
  ['callout-caution'] = { variante = 'important', icona = 'it-error', titolo = 'Avvertenza' },
  ['callout-important'] = { variante = 'danger', icona = 'it-close-circle', titolo = 'Importante' },
}

local function variante_di(div)
  for _, classe in ipairs(div.classes) do
    if VARIANTI[classe] then
      return classe, VARIANTI[classe]
    end
  end
  return nil, nil
end

-- il titolo può stare nell'attributo title= oppure nel primo heading del div
local function estrai_titolo(div, predefinito)
  if div.attributes['title'] then
    return div.attributes['title'], div.content
  end
  local blocchi = div.content
  if #blocchi > 0 and blocchi[1].t == 'Header' then
    local titolo = pandoc.utils.stringify(blocchi[1].content)
    local resto = pandoc.List()
    for i = 2, #blocchi do
      resto:insert(blocchi[i])
    end
    return titolo, resto
  end
  return predefinito, blocchi
end

-- gli attributi che Quarto documenta per i callout, oltre a title:
--   collapse="true|false"  richiudibile (chiuso o già aperto)
--   icon="false"           senza icona
--   appearance="simple|minimal"  versione senza riquadro; minimal è anche senza icona
local function falso(v)
  return v == 'false' or v == '0'
end

local progressivo = 0

function Div(div)
  if not quarto.doc.is_format('html:js') then
    return nil
  end

  local classe, def = variante_di(div)
  if not def then
    return nil
  end

  local titolo, contenuto = estrai_titolo(div, def.titolo)

  local aspetto = div.attributes['appearance']
  local collapse = div.attributes['collapse']
  local con_icona = not falso(div.attributes['icon']) and aspetto ~= 'minimal'

  -- le classi diverse da callout-* restano sull'elemento esterno
  local extra = pandoc.List()
  for _, c in ipairs(div.classes) do
    if c ~= classe and c ~= 'callout' then
      extra:insert(c)
    end
  end

  local id = div.identifier ~= '' and (' id="' .. div.identifier .. '"') or ''
  local classi = 'callout ' .. def.variante
  -- il callout senza riquadro del design system è .callout-highlight
  if aspetto == 'simple' or aspetto == 'minimal' then
    classi = classi .. ' callout-highlight'
  end
  if #extra > 0 then
    classi = classi .. ' ' .. table.concat(extra, ' ')
  end

  local icona = con_icona
    and ('<svg class="icon" aria-hidden="true"><use href="#' .. def.icona .. '"></use></svg>')
    or ''

  local apertura = pandoc.List({
    '<div class="' .. classi .. '"' .. id .. '>',
    '<div class="callout-inner">',
    '<div class="callout-title">',
    icona,
    '<span class="text">' .. titolo .. '</span>',
    '</div>',
  })
  local chiusura = pandoc.List({ '</div>', '</div>' })

  -- richiudibile: il collapse di Bootstrap Italia, con il pulsante del design system
  if collapse ~= nil then
    progressivo = progressivo + 1
    local base = (div.identifier ~= '' and div.identifier or 'callout') .. '-' .. progressivo
    local corpo, intestazione = base .. '-corpo', base .. '-toggle'
    local aperto = falso(collapse)
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

  local risultato = pandoc.List({ pandoc.RawBlock('html', table.concat(apertura, '\n')) })
  risultato:extend(contenuto)
  risultato:insert(pandoc.RawBlock('html', table.concat(chiusura, '\n')))
  return risultato
end
