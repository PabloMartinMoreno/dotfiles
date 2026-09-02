-- Los colores viven en lua/config/highlights.lua, cargado después del
-- colorscheme. Acá solo va la forma.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ft = "markdown",
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      -- Sin render en insert: el frontmatter y las tablas se editan crudos.
      render_modes = { "n", "c", "t" },
      latex = { enabled = false },
      sign = { enabled = false },

      heading = {
        position = "inline",
        width = "full",
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        left_pad = 0,
        right_pad = 1,
      },

      -- El vault es tablas: esquema, matrices de dialectos, campos de telemetría.
      pipe_table = { preset = "round", cell = "trimmed" },

      -- Que la fila bajo el cursor no se des-renderice: las tablas dejaban de
      -- estar alineadas justo donde estabas mirando.
      anti_conceal = {
        ignore = {
          table_border = true,
          head_border = true,
          code_background = true,
          sign = true,
        },
      },

      -- `style = "none"` era un preset que hacía `enabled = false`: apagaba el
      -- render de código entero. Se configura a mano para tener el encabezado
      -- de lenguaje sin fondo, que es lo que rompía la transparencia.
      code = {
        disable_background = true, -- sin relleno: la transparencia se mantiene
        border = "thin", -- ▄▀ arriba y abajo en vez de un bloque de color
        language_icon = true,
        language_name = true,
        position = "right", -- el icono no empuja la primera línea
        inline = true, -- el `código` en línea también se marca
      },

      bullet = { icons = { "●", "○", "◆", "◇" } },
      quote = { icon = "▎" },

      checkbox = {
        position = "inline",
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          curso = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },

      -- El vault usa callouts de Obsidian, no de GitHub.
      callout = {
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Importante", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Atención", highlight = "RenderMarkdownWarn" },
        danger = { raw = "[!DANGER]", rendered = "󱐌 Peligro", highlight = "RenderMarkdownError" },
        info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        note = { raw = "[!NOTE]", rendered = "󰋽 Nota", highlight = "RenderMarkdownInfo" },
        abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Resumen", highlight = "RenderMarkdownInfo" },
      },
    },
    keys = {
      { "<leader>om", "<cmd>RenderMarkdown toggle<cr>", desc = "Render markdown on/off" },
      {
        "<leader>oz",
        function()
          Snacks.zen()
        end,
        desc = "Modo zen",
      },
    },
  },
}
