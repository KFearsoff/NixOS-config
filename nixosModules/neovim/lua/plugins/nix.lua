return {
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
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "alejandra" }
              }
            }
          },
        },
      },
    },
  },
}
