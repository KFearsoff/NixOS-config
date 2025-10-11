return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ["*"] = { "editorconfig-checker" },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = {},
        html = {},
        nixd = {
          nixpkgs = {
            expr = '(builtins.getFlake "/home/nixchad/NixOS-config").inputs.nixpkgs { }',
          },
          formatting = {
            command = { "nixfmt" },
          },
          options = {
            nixos = {
              expr = '(builtins.getFlake "/home/nixchad/NixOS-config").nixosConfigurations.blueberry.options',
            },
            home_manager = {
              expr = '(builtins.getFlake "/home/nixchad/NixOS-config").nixosConfigurations.blueberry.options.home-manager.users.type.getSubOptions []',
            },
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "nix" } },
  },
}
