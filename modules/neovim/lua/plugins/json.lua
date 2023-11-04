return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          -- Nix has a different executable name
          cmd = { "vscode-json-languageserver", "--stdio" },
        },
      },
    },
  },
}
