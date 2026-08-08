-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v", "x" }, "<C-d>", "<C-d>zz", { desc = "Scroll down y centrar" })
vim.keymap.set({ "n", "v", "x" }, "<C-u>", "<C-u>zz", { desc = "Scroll up y centrar" })
