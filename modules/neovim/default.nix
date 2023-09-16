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

          # UI
          bufferline-nvim
          gitsigns-nvim
          edgy-nvim
          toggleterm-nvim
          trouble-nvim
          lualine-nvim
          which-key-nvim
          nvim-web-devicons
          mini-nvim
          noice-nvim
          nui-nvim
          nvim-notify
          nvim-lsp-notify
          neo-tree-nvim
          nvim-navic
          dressing-nvim

          # project management
          alpha-nvim
          project-nvim
          vim-lastplace
          neoconf-nvim
          persistence-nvim

          # smart typing
          indent-blankline-nvim
          guess-indent-nvim
          vim-illuminate

          # LSP
          nvim-lspconfig
          rust-tools-nvim
          crates-nvim
          null-ls-nvim
          nvim-lightbulb # lightbulb for quick actions
          nvim-code-action-menu # code action menu
          neodev-nvim

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

          # search functionality
          plenary-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          nvim-spectre
          flash-nvim

          # treesitter
          (nvim-treesitter.withPlugins (p:
            with p; [
              bash
              c
              dockerfile
              json
              lua
              nix
              query
              ron
              rust
              toml
              vim
              vimdoc
              yaml
            ]))
          SchemaStore-nvim # load known formats for json and yaml

          # comments
          nvim-ts-context-commentstring
          todo-comments-nvim

          # leap
          vim-repeat
          leap-nvim
          flit-nvim

          # DAP
          nvim-dap
          nvim-dap-ui
          nvim-dap-virtual-text

          # neotest
          neotest
          neotest-rust

          lazy-nvim
          vim-startuptime
        ];

        extraPackages = with pkgs; [
          rust-analyzer
          graphviz
          gcc # needed for nvim-treesitter

          # LSP
          nodePackages.bash-language-server
          nodePackages.dockerfile-language-server-nodejs
          docker-compose-language-service
          nodePackages.vscode-json-languageserver
          lua-language-server
          rnix-lsp
          nodePackages.yaml-language-server
          marksman

          # null-ls
          shellcheck
          statix
          actionlint
          deadnix
          editorconfig-checker
          stylua
          # hadolint
          nodePackages.markdownlint-cli
          alejandra
          shfmt
        ];

        extraLuaConfig = ''
          vim.g.mapleader = " "
          require("lazy").setup({
            spec = {
              { import = "plugins" },
              { import = "languages" },
            },
            performance = {
              reset_packpath = false,
              rtp = {
                  reset = false,
                }
              },
            dev = {
              path = "${pkgs.vimUtils.packDir config.home-manager.users.nixchad.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
            },
            install = {
              missing = false,
            },
          })
        '';
      };

      xdg.configFile."nvim/lua" = {
        recursive = true;
        source = ./lua;
      };
    };
  };
}
