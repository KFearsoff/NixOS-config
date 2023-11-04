return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "alejandra" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        nix = {
          -- "deadnix",
          "statix",
        },
      },
      -- linters = {
      --   deadnix = {
      --     cmd = "deadnix",
      --     parser = {},
      --   },
      -- },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rnix = {
          document_formatting_provider = nil,
        },
      },
    },
  },
}
