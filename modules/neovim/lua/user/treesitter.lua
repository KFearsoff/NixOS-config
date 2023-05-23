local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

local parser_install_dir = vim.fn.stdpath("cache") .. "/treesitters"
vim.fn.mkdir(parser_install_dir, "p")
vim.opt.runtimepath:append(parser_install_dir)

configs.setup {
  parser_install_dir = parser_install_dir,
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "bash", "comment", "dockerfile", "go", "gomod", "hcl", "json", "nix", "python", "rust", "toml", "yaml" },
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true, disable = { "yaml" } },
  rainbow = {
    enable = true,
    -- list of languages you want to disable the plugin for
    disable = { "jsx", "cpp" },
    -- Which query to use for finding delimeters
    query = "rainbow-parens",
    -- Highlight the entire buffer all at once
    strategy = require("ts-rainbow").strategy.global,
  },
}
