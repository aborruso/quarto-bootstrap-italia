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

function Div(div)
  if not quarto.doc.is_format('html:js') then
    return nil
  end

  local classe, def = variante_di(div)
  if not def then
    return nil
  end

  local titolo, contenuto = estrai_titolo(div, def.titolo)

  -- le classi diverse da callout-* restano sull'elemento esterno
  local extra = pandoc.List()
  for _, c in ipairs(div.classes) do
    if c ~= classe and c ~= 'callout' then
      extra:insert(c)
    end
  end

  local id = div.identifier ~= '' and (' id="' .. div.identifier .. '"') or ''
  local classi = 'callout ' .. def.variante
  if #extra > 0 then
    classi = classi .. ' ' .. table.concat(extra, ' ')
  end

  local apertura = table.concat({
    '<div class="' .. classi .. '"' .. id .. '>',
    '<div class="callout-inner">',
    '<div class="callout-title">',
    '<svg class="icon" aria-hidden="true"><use href="#' .. def.icona .. '"></use></svg>',
    '<span class="text">' .. titolo .. '</span>',
    '</div>',
  }, '\n')

  local risultato = pandoc.List({ pandoc.RawBlock('html', apertura) })
  risultato:extend(contenuto)
  risultato:insert(pandoc.RawBlock('html', '</div>\n</div>'))
  return risultato
end
