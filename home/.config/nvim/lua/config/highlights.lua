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

  -- Sin fondo en los bloques de código: si no, rompen la transparencia.
  for _, grupo in ipairs({
    "RenderMarkdownCode",
    "RenderMarkdownCodeInline",
    "RenderMarkdownCodeBorder",
  }) do
    vim.api.nvim_set_hl(0, grupo, { bg = "NONE", fg = p.comentario })
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

  -- Frontmatter apagado: es metadata, no contenido.
  vim.api.nvim_set_hl(0, "@property.yaml", { fg = p.comentario })
end

aplicar()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("highlights-markdown", { clear = true }),
  callback = aplicar,
})
