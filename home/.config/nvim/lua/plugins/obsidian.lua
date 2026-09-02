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

-- Saltar a una nota. `Obsidian quick_switch` es un picker de archivos: filtra
-- ruta y nombre, no abre el frontmatter, y por lo tanto nunca encuentra por
-- alias. Como las convenciones del vault exigen el alias en el otro idioma,
-- esto lee los aliases y los suma al texto buscable de cada nota: una sola
-- búsqueda que acierta tanto con el nombre como con el alias.
local function aliases_de(ruta)
  local aliases, en_fm, en_lista = {}, false, false
  local function limpiar(s)
    return (vim.trim(s):gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1"))
  end
  for linea in io.lines(ruta) do
    if linea:match("^%-%-%-%s*$") then
      if en_fm then
        break
      end
      en_fm = true
    elseif en_fm then
      local inline = linea:match("^aliases:%s*%[(.*)%]%s*$")
      if inline then
        for a in inline:gmatch("[^,]+") do
          table.insert(aliases, limpiar(a))
        end
        en_lista = false
      elseif linea:match("^aliases:%s*$") then
        en_lista = true
      elseif en_lista then
        local a = linea:match("^%s+%-%s*(.+)$")
        if a then
          table.insert(aliases, limpiar(a))
        else
          en_lista = false
        end
      end
    end
  end
  return aliases
end

local function saltar_a_nota()
  Snacks.picker({
    title = "Notas — nombre y alias",
    finder = function()
      local items = {}
      for _, ruta in ipairs(vim.fn.globpath(vault, "**/*.md", false, true)) do
        local nombre = vim.fn.fnamemodify(ruta, ":t:r")
        local aliases = aliases_de(ruta)
        table.insert(items, {
          file = ruta,
          nombre = nombre,
          aliases = aliases,
          text = nombre .. " " .. table.concat(aliases, " "),
        })
      end
      return items
    end,
    format = function(item)
      local linea = { { item.nombre, "SnacksPickerFile" } }
      if #item.aliases > 0 then
        table.insert(linea, { "  " .. table.concat(item.aliases, " · "), "SnacksPickerComment" })
      end
      return linea
    end,
    confirm = function(picker, item)
      picker:close()
      vim.cmd.edit(vim.fn.fnameescape(item.file))
    end,
  })
end

-- Índice de la nota. El `Obsidian toc` de la v3.16.6 usa vim.pos.cursor, que
-- rompe en nvim 0.12. Esto lee los headings del buffer y salta al elegido.
local function indice_nota()
  local items = {}
  for nr, linea in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local almohadillas, texto = linea:match("^(#+)%s+(.+)$")
    if almohadillas then
      table.insert(items, {
        lnum = nr,
        texto = string.rep("  ", #almohadillas - 1) .. texto,
      })
    end
  end
  if #items == 0 then
    vim.notify("la nota no tiene headings", vim.log.levels.INFO)
    return
  end
  vim.ui.select(items, {
    prompt = "Índice",
    format_item = function(i)
      return i.texto
    end,
  }, function(elegido)
    if elegido then
      vim.api.nvim_win_set_cursor(0, { elegido.lnum, 0 })
      vim.cmd("normal! zz")
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
      { "<leader>oq", saltar_a_nota, desc = "Saltar a nota (nombre o alias)" },
      { "<leader>on", "<cmd>Obsidian new_from_template<cr>", desc = "Nota nueva desde plantilla" },
      { "<leader>oN", "<cmd>Obsidian new<cr>", desc = "Nota nueva vacía" },
      { "<leader>ot", "<cmd>Obsidian template<cr>", desc = "Insertar plantilla acá" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Enlaces salientes" },
      { "<leader>og", "<cmd>Obsidian tags<cr>", desc = "Tags" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Renombrar (arrastra enlaces)" },
      { "<leader>oi", indice_nota, desc = "Índice de la nota" },
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
