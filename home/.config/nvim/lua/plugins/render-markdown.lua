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
      pipe_table = { preset = "round", cell = "padded" },

      -- Sin fondo ni borde: cualquier relleno rompe la transparencia.
      code = { style = "none" },

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
