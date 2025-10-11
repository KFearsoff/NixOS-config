-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.completeopt = "menu,menuone,noselect,noinsert"
opt.conceallevel = 0 -- So that `` is visible in markdown
opt.wrap = true      -- Enable line wrap
vim.g.lazyvim_python_lsp = "basedpyright"
