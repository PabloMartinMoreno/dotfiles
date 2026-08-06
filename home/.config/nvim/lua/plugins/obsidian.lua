-- Ruta del vault. Se define con la variable de entorno OBSIDIAN_VAULT para que
-- esta config no dependa de dónde lo tenga cada máquina.
local vault = vim.fn.expand(vim.env.OBSIDIAN_VAULT or "~/vault")
local nombre_vault = vim.fn.fnamemodify(vault, ":t"):lower()

-- Script de consultas propio del vault: lee el frontmatter de las notas y
-- responde preguntas sobre el grafo. Si el vault no lo tiene, el atajo avisa.
local SCRIPT_CONSULTAS = "/900-meta/consultas.py"

local function consultas()
  local script = vault .. SCRIPT_CONSULTAS
  if vim.fn.filereadable(script) == 0 then
    vim.notify("no hay script de consultas en " .. script, vim.log.levels.WARN)
    return
  end
  local salida = vim.system({ script, "--ayuda-comandos" }, { text = true }):wait()
  local cmds = {}
  for linea in (salida.stdout or ""):gmatch("[^\r\n]+") do
    table.insert(cmds, linea)
  end
  if #cmds == 0 then
    cmds = { "todo" }
  end
  vim.ui.select(cmds, { prompt = "consultas" }, function(choice)
    if choice then
      Snacks.terminal({ script, choice }, { cwd = vault })
    end
  end)
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    -- Solo dentro del vault: un .md de cualquier otro lado no carga el plugin.
    event = {
      "BufReadPre " .. vault .. "/*.md",
      "BufNewFile " .. vault .. "/*.md",
    },
    dependencies = { "folke/snacks.nvim" },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        { name = nombre_vault, path = vault },
      },

      -- El esquema del vault lo manda 900-meta/Esquema de frontmatter.md.
      -- Con esto activado el plugin inyecta id/aliases/tags y reordena al guardar.
      frontmatter = { enabled = false },

      -- El nombre de archivo ES el identificador del enlace: título, no un ID zettel.
      note_id_func = function(...)
        return require("obsidian.builtin").title_id(...)
      end,
      picker = { name = "snacks.picker" },
      templates = { folder = "999-plantillas" },

      -- El render lo hace render-markdown.nvim. Con los dos activos se duplican
      -- checkboxes y bullets.
      ui = { enable = false },
    },
    keys = {
      { "<leader>o", "", desc = "+obsidian" },
      { "<leader>oo", "<cmd>Obsidian search<cr>", desc = "Buscar en el vault" },
      { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Saltar a nota" },
      { "<leader>on", "<cmd>Obsidian new_from_template<cr>", desc = "Nota nueva desde plantilla" },
      { "<leader>oN", "<cmd>Obsidian new<cr>", desc = "Nota nueva vacía" },
      { "<leader>ot", "<cmd>Obsidian template<cr>", desc = "Insertar plantilla acá" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Enlaces salientes" },
      { "<leader>og", "<cmd>Obsidian tags<cr>", desc = "Tags" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Renombrar (arrastra enlaces)" },
      { "<leader>oi", "<cmd>Obsidian toc<cr>", desc = "Índice de la nota" },
      {
        "<leader>op",
        function()
          -- Solo las matrices de referencia: los cheatsheets, sin el resto del vault.
          Snacks.picker.files({ cwd = vault .. "/900-meta", pattern = "matriz de referencia" })
        end,
        desc = "Matrices de referencia (payloads)",
      },
      { "<leader>oc", consultas, desc = "consultas.py" },
      { "gf", "<cmd>Obsidian follow_link<cr>", desc = "Seguir wikilink", ft = "markdown" },
      { "<leader>ox", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Alternar checkbox" },
    },
  },
}
