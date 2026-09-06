-- Highlights de markdown, aplicados DESPUÉS del colorscheme.
-- Si se definen dentro del spec de un plugin, el colorscheme los pisa al cargar.
-- Por eso init.lua llama a este módulo recién después de config.lazy.

local p = require("config.paleta")

local function aplicar()
  for nivel, color in ipairs(p.headings) do
    -- Barra sólida a ancho completo: el color es el fondo, el texto va oscuro.
    local barra = { fg = p.heading_texto, bg = color, bold = true }

    -- render-markdown pinta la línea entera con estos grupos.
    vim.api.nvim_set_hl(0, "RenderMarkdownH" .. nivel .. "Bg", barra)
    -- Ícono del heading: mismo esquema, para que no corte la barra.
    vim.api.nvim_set_hl(0, "RenderMarkdownH" .. nivel, barra)
    -- El texto del heading lo colorea treesitter, no render-markdown.
    vim.api.nvim_set_hl(0, "@markup.heading." .. nivel .. ".markdown", barra)
  end

  -- Bloques de código sin fondo, para no romper la transparencia. Pero SIN
  -- forzarles un `fg`: hacerlo pintaba el bloque entero del gris de comentario
  -- y tapaba los colores que treesitter ya aplica adentro del fence.
  vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
  -- El borde ▄▀ y el encabezado del lenguaje: visibles, sin gritar.
  vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorder", { bg = "NONE", fg = p.violeta })
  vim.api.nvim_set_hl(0, "RenderMarkdownCodeInfo", { bg = "NONE", fg = p.violeta })
  -- Código en línea: el vault está lleno de flags y campos entre backticks.
  -- Con el gris de comentario no se distinguían de la prosa.
  for _, grupo in ipairs({
    "RenderMarkdownCodeInline",
    "@markup.raw.markdown_inline",
  }) do
    vim.api.nvim_set_hl(0, grupo, { bg = "NONE", fg = p.naranja })
  end

  -- Negrita: el peso de fuente solo no se distingue en esta tipografía. Un color
  -- propio la separa de la prosa. rosa solo lo usa la cabecera de tabla (bloque),
  -- así que en línea no choca con nada.
  for _, grupo in ipairs({ "@markup.strong", "@markup.strong.markdown_inline" }) do
    vim.api.nvim_set_hl(0, grupo, { fg = p.rosa, bold = true })
  end

  vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = p.violeta })
  vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { fg = p.comentario })
  vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { fg = p.rosa })
  vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = p.comentario })
  vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = p.verde })
  vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = p.comentario })

  -- Wikilinks y enlaces: el grafo se navega por acá, que se vean.
  vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = p.cyan, underline = true })
  vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { fg = p.cyan })

  -- Callouts: color por semántica de la palabra, no el default del tema.
  -- Cada callout de render-markdown.lua apunta a uno de estos grupos.
  vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { fg = p.cyan }) -- info · nota · resumen
  vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { fg = p.dorado }) -- tip
  vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { fg = p.naranja }) -- atención
  vim.api.nvim_set_hl(0, "RenderMarkdownError", { fg = p.rojo_fuerte }) -- peligro
  vim.api.nvim_set_hl(0, "RenderMarkdownHint", { fg = p.violeta }) -- importante

  -- Frontmatter apagado: es metadata, no contenido.
  vim.api.nvim_set_hl(0, "@property.yaml", { fg = p.comentario })

  -- Número de la línea del cursor. eldritch lo pone verde, que se confunde con
  -- el verde de los H3.
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = p.cyan_brillante, bold = true })
end

aplicar()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("highlights-markdown", { clear = true }),
  callback = aplicar,
})
