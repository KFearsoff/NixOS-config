{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.neovim;
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
          # theme
          dracula-nvim

          # dashboard
          alpha-nvim
          trouble-nvim

          # line
          lualine-nvim

          # smart typing
          editorconfig-nvim
          indent-blankline-nvim
          nvim-autopairs
          guess-indent-nvim
          vim-illuminate

          vim-lastplace
          which-key-nvim
          nvim-web-devicons
          nvim-tree-lua
          mini-nvim

          # LSP
          nvim-lspconfig
          rust-tools-nvim
          null-ls-nvim
          nvim-lightbulb # lightbulb for quick actions
          nvim-code-action-menu # code action menu

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
          (nvim-treesitter.withPlugins (p:
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
          SchemaStore-nvim # load known formats for json and yaml

          # comments
          comment-nvim
          nvim-ts-context-commentstring
          todo-comments-nvim

          gitsigns-nvim

          # tabs
          bufferline-nvim
          edgy-nvim

          # terminal
          toggleterm-nvim

          # project management
          project-nvim

          # leap
          vim-repeat
          leap-nvim
        ];

        extraPackages = with pkgs; [
          rust-analyzer
          graphviz
          gcc # needed for nvim-treesitter

          # LSP
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
          marksman

          # null-ls
          shellcheck
          statix
          actionlint
          deadnix
          editorconfig-checker
          # hadolint
          nodePackages.jsonlint
          nodePackages.markdownlint-cli
          alejandra
          shfmt
        ];

        extraLuaConfig = ''
          vim.g.loaded_netwr = 1
          vim.g.loaded_netrwPlugin = 1
          vim.loader.enable() -- byte-compile and cache lua files

          require "user.options"
          require "user.colorscheme"
          require "user.keymaps"
          require "user.cmp"
          require "user.lsp"
          require "user.telescope"
          require "user.treesitter"
          require "user.autopairs"
          require "user.comment"
          require "user.gitsigns"
          require "user.nvim-tree"
          require "user.bufferline"
          require "user.toggleterm"
          require "user.lualine"
          require "user.project"
          require "user.alpha"
          require "user.whichkey"
          require "user.leap"
          require "user.guess-indent"
          require "user.indent-blankline"
          require "user.edgy"
          require "user.mini"
          require "user.lightbulb"
        '';
      };

      xdg.configFile."nvim/lua" = {
        recursive = true;
        source = ./lua;
      };
    };
  };
}
