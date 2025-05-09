{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.neovim;
in
{
  options.nixchad.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    hm = {
      home.sessionVariables = {
        EDITOR = "nvim";
      };
      programs.nushell.environmentVariables = {
        EDITOR = "'nvim'";
      };

      programs.neovim = {
        enable = true;
        vimAlias = true;
        vimdiffAlias = true;
        withNodeJs = true;

        plugins = with pkgs.vimPlugins; [
          # Plugin Manager
          lazy-nvim
          # Base Distro
          LazyVim

          # Coding
          mini-pairs
          ts-comments-nvim
          mini-ai
          lazydev-nvim

          # Blink
          blink-cmp
          friendly-snippets

          # Editor
          neo-tree-nvim
          grug-far-nvim
          flash-nvim
          which-key-nvim
          gitsigns-nvim
          trouble-nvim
          todo-comments-nvim

          # Fzf
          fzf-lua

          # Formatting
          conform-nvim

          # Linting
          nvim-lint

          # LSP
          nvim-lspconfig

          # TreeSitter
          nvim-treesitter.withAllGrammars
          nvim-treesitter-textobjects
          nvim-ts-autotag

          # UI
          bufferline-nvim
          lualine-nvim
          noice-nvim
          mini-icons
          nui-nvim

          # Util
          snacks-nvim
          persistence-nvim
          plenary-nvim

          # Mini-comment Extra
          mini-comment
          nvim-ts-context-commentstring

          # Mini-surround Extra
          mini-surround

          # DAP Core Extra
          nvim-dap
          nvim-dap-ui
          nvim-dap-virtual-text
          nvim-nio

          # DAP Neovim Lua Adapter Extra
          # one-small-step-for-vimkind

          # Aerial Extra
          aerial-nvim

          # Illuminate Extra
          vim-illuminate

          # Inc-rename Extra
          inc-rename-nvim

          # Leap Extra
          flit-nvim
          leap-nvim
          vim-repeat

          # Mini-diff Extra
          mini-diff

          # Navic Extra
          nvim-navic

          # Overseer Extra
          overseer-nvim

          # Clangd Extra
          clangd_extensions-nvim

          # Helm Extra
          vim-helm

          # JSON/YAML Extra
          SchemaStore-nvim # load known formats for json and yaml

          # Markdown Extra
          markdown-preview-nvim
          render-markdown-nvim

          # Python Extra
          neotest-python
          nvim-dap-python

          # Rust Extra
          crates-nvim
          rustaceanvim

          # Terraform Extra
          # telescope-terraform-doc-nvim
          # telescope-terraform-nvim

          # LSP Extra
          neoconf-nvim
          none-ls-nvim

          # Test Extra
          neotest

          # Edgy Extra
          edgy-nvim

          # Mini-animate Extra
          mini-animate

          # Treesitter-context Extra
          nvim-treesitter-context

          # Project Extra
          project-nvim

          # Startuptime
          vim-startuptime

          nvim-web-devicons
          nvim-notify
          nvim-lsp-notify

          # smart typing
          guess-indent-nvim

          # LSP
          nvim-lightbulb # lightbulb for quick actions
          nvim-code-action-menu # code action menu
        ];

        extraPackages = with pkgs; [
          gcc # needed for nvim-treesitter

          # HTML, CSS, JSON
          vscode-langservers-extracted

          # LazyVim defaults
          stylua
          shfmt

          # Markdown extra
          markdownlint-cli2
          marksman

          # JSON and YAML extras
          nodePackages.yaml-language-server

          # Custom
          editorconfig-checker
          shellcheck
        ];

        extraLuaConfig = ''
          vim.g.mapleader = " "
          require("lazy").setup({
            spec = {
              { "LazyVim/LazyVim", import = "lazyvim.plugins" },
              -- import any extras modules here
              { import = "lazyvim.plugins.extras.coding.mini-comment" },
              { import = "lazyvim.plugins.extras.coding.mini-surround" },
              { import = "lazyvim.plugins.extras.dap.core" },
              { import = "lazyvim.plugins.extras.dap.nlua" },
              -- We need to use Edgy before Aerial
              { import = "lazyvim.plugins.extras.ui.edgy" },
              { import = "lazyvim.plugins.extras.editor.aerial" },
              { import = "lazyvim.plugins.extras.editor.illuminate" },
              { import = "lazyvim.plugins.extras.editor.inc-rename" },
              { import = "lazyvim.plugins.extras.editor.leap" },
              { import = "lazyvim.plugins.extras.editor.mini-diff" },
              { import = "lazyvim.plugins.extras.editor.navic" },
              { import = "lazyvim.plugins.extras.editor.overseer" },
              { import = "lazyvim.plugins.extras.lang.clangd" },
              { import = "lazyvim.plugins.extras.lang.docker" },
              { import = "lazyvim.plugins.extras.lang.helm" },
              { import = "lazyvim.plugins.extras.lang.json" },
              { import = "lazyvim.plugins.extras.lang.markdown" },
              { import = "lazyvim.plugins.extras.lang.nushell" },
              { import = "lazyvim.plugins.extras.lang.python" },
              { import = "lazyvim.plugins.extras.lang.rust" },
              { import = "lazyvim.plugins.extras.lang.terraform" },
              { import = "lazyvim.plugins.extras.lang.yaml" },
              { import = "lazyvim.plugins.extras.lsp.neoconf" },
              { import = "lazyvim.plugins.extras.lsp.none-ls" },
              { import = "lazyvim.plugins.extras.test.core" },
              { import = "lazyvim.plugins.extras.ui.mini-animate" },
              { import = "lazyvim.plugins.extras.ui.treesitter-context" },
              { import = "lazyvim.plugins.extras.util.project" },
              { import = "lazyvim.plugins.extras.util.startuptime" },
              -- import/override with your plugins
              { import = "plugins" },
            },
            defaults = {
              -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
              -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
              lazy = false,
              -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
              -- have outdated releases, which may break your Neovim install.
              version = false, -- always use the latest git commit
              -- version = "*", -- try installing the latest stable version for plugins that support semver
            },
            performance = {
              -- Used for NixOS
              reset_packpath = false,
              rtp = {
                reset = false,
                -- disable some rtp plugins
                disabled_plugins = {
                  "gzip",
                  -- "matchit",
                  -- "matchparen",
                  -- "netrwPlugin",
                  "tarPlugin",
                  "tohtml",
                  "tutor",
                  "zipPlugin",
                },
              }
            },
            dev = {
              path = "${pkgs.vimUtils.packDir config.home-manager.users.nixchad.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
              patterns = {""},
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
