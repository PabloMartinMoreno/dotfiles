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
