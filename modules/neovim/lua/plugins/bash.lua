return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
      },
    }
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {}
      },
    }
  }
}
