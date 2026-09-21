-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- LazyVim trae wrap=false. Lo activamos: línea larga se ve entera en pantalla
-- (wrap visual, no newline real) y la continuación no repite numeración.
opt.wrap = true
opt.linebreak = true -- corta en espacios, no al medio de una palabra
opt.breakindent = true -- la continuación mantiene la sangría de la línea
