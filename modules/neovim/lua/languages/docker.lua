return {
  {
    "nvim-treesitter/nvim-treesitter",
    dev = true,
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "dockerfile" })
      end
    end,
  },
  -- TODO: enable once hadolint is fixed
  -- {
  --   "jose-elias-alvarez/null-ls.nvim",
  --   dev = true,
  --   opts = function(_, opts)
  --     local nls = require("null-ls")
  --     opts.sources = opts.sources or {}
  --     vim.list_extend(opts.sources, {
  --       nls.builtins.diagnostics.hadolint,
  --     })
  --   end,
  -- },
  {
    "neovim/nvim-lspconfig",
    dev = true,
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
}
