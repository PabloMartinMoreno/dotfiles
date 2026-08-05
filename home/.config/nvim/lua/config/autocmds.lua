-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim activa spell con spelllang=en en markdown. Con notas en español eso
-- subraya casi cada palabra. Solo hay diccionario `en` instalado.
-- conceallevel no se toca: lo maneja render-markdown.
local function markdown_lectura()
  vim.opt_local.spell = false
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true -- no corta palabras al medio
  vim.opt_local.breakindent = true -- la continuación mantiene la sangría
  vim.opt_local.showbreak = "↳ "
  vim.opt_local.textwidth = 80 -- el texto nuevo se corta solo; da aire a la nota

  -- Plegar por nivel de heading. El número es el nivel que queda visible:
  -- z2 en una nota de tradecraft deja las cuatro secciones fijas a la vista.
  -- Los nativos zR (abrir todo), zM (cerrar todo) y za (alternar) siguen igual.
  for nivel = 1, 6 do
    vim.keymap.set("n", "z" .. nivel, function()
      vim.wo.foldlevel = nivel - 1
    end, { buffer = true, desc = "Plegar a H" .. nivel })
  end

  -- Corrector: el vault mezcla prosa en español con términos en inglés, así que
  -- van los dos idiomas juntos. Sugerencias con z=, agregar palabra con zg.
  vim.keymap.set("n", "<leader>os", function()
    vim.opt_local.spelllang = "es,en"
    vim.opt_local.spell = not vim.wo.spell
    vim.notify("corrector " .. (vim.wo.spell and "activado (es+en)" or "apagado"))
  end, { buffer = true, desc = "Corrector es+en" })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown-lectura", { clear = true }),
  pattern = "markdown",
  callback = markdown_lectura,
})

-- Este archivo se carga en VeryLazy, después de que el primer buffer ya abrió:
-- sin esto, `nvim nota.md` no recibe los ajustes.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
    vim.api.nvim_buf_call(buf, markdown_lectura)
  end
end
