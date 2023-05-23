{
  config,
  lib,
  pkgs,
  nix-colors,
  ...
}:
with lib; let
  cfg = config.nixchad.neovim;
  inherit (nix-colors.lib-contrib {inherit pkgs;}) vimThemeFromScheme;
  inherit (config.hm) colorscheme;
in {
  options.nixchad.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    hm = {
      home.sessionVariables = {
        EDITOR = "nvim";
      };

      programs.neovim = {
        enable = true;
        package = pkgs.neovim-nightly;
        vimAlias = true;
        vimdiffAlias = true;
        withNodeJs = true;

        plugins = with pkgs.vimPlugins; [
          {
            plugin = vimThemeFromScheme {scheme = colorscheme;};
            type = "lua";
            config = ''
              vim.cmd.colorscheme('nix-${colorscheme.slug}')
            '';
          }
          vim-airline

          editorconfig-nvim
          indentLine
          vim-lastplace

          # LSP
          nvim-lspconfig
          rust-tools-nvim

          # cmp plugins
          nvim-cmp # completion plugin
          cmp-buffer # buffer completions
          cmp-path # path completions
          cmp-cmdline # cmdline completions
          cmp_luasnip # snipper completions
          cmp-nvim-lsp # LSP completions

          # snippets
          luasnip # snippet engine
          friendly-snippets # a bunch of snippets to use

          # telescope
          plenary-nvim
          telescope-nvim
          telescope-media-files-nvim
          telescope-fzf-native-nvim

          # treesitter
          (pkgs.myVimPlugins.nvim-treesitter.withPlugins (p:
            with p; [
              c
              go
              vim
              nix
              lua
              hcl
              yaml
              toml
              rust
              json
              bash
              gomod
              python
              dockerfile
              query
              comment
            ]))
          nvim-ts-rainbow2
        ];

        extraPackages = with pkgs; [
          rust-analyzer
          graphviz

          nodePackages.bash-language-server
          nodePackages.dockerfile-language-server-nodejs
          gopls
          helm-ls
          nodePackages.vscode-json-languageserver
          lua-language-server
          nodePackages.pyright
          rnix-lsp
          terraform-ls
          nodePackages.yaml-language-server
          gcc # needed for nvim-treesitter
        ];

        extraLuaConfig = ''
          require "user.options"
          require "user.keymaps"
          require "user.cmp"
          require "user.lsp"
          require "user.telescope"
          require "user.treesitter"
        '';
      };

      xdg.configFile."nvim/lua" = {
        recursive = true;
        source = ./lua;
      };
    };
  };
}
