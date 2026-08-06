--[[
  Shortcode `icona`: le icone del design system senza scrivere SVG a mano.

      {{< icona it-file >}}                icona semplice, decorativa
      {{< icona it-file primary >}}        con il colore primario (classe icon-primary)
      {{< icona it-user alt="Utente" >}}   icona che porta significato: viene esposta
                                           agli screen reader invece di essere nascosta

  Lo sprite è già nella pagina (lo inserisce bootstrap-italia.lua), quindi il
  riferimento `<use href="#nome">` funziona da qualunque sottocartella.

  Senza questo shortcode l'unica strada sarebbe scrivere l'SVG in HTML dentro il
  Markdown: il tema esiste per evitarlo.
]]

local function classi_da(args)
  local classi = { 'icon' }
  for i = 2, #args do
    local c = pandoc.utils.stringify(args[i])
    if c ~= '' then
      -- si scrive `primary`, non `icon-primary`: la forma lunga resta accettata
      if not c:match('^icon%-') then
        c = 'icon-' .. c
      end
      table.insert(classi, c)
    end
  end
  return table.concat(classi, ' ')
end

function icona(args, kwargs)
  if #args == 0 then
    quarto.log.warning('shortcode icona: manca il nome dell\'icona')
    return pandoc.Null()
  end

  local nome = pandoc.utils.stringify(args[1])
  local alt = kwargs['alt'] and pandoc.utils.stringify(kwargs['alt']) or ''

  local accessibilita = alt ~= ''
    and (' role="img" aria-label="' .. alt:gsub('"', '&quot;') .. '"')
    or ' aria-hidden="true"'

  local svg = '<svg class="' .. classi_da(args) .. '"' .. accessibilita
    .. '><use href="#' .. nome .. '"></use></svg>'

  return pandoc.RawInline('html', svg)
end
