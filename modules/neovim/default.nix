{
  config,
  lib,
  pkgs,
  username,
  nix-colors,
  ...
}: with lib; let
  cfg = config.nixchad.neovim;
  inherit (nix-colors.lib-contrib {inherit pkgs;}) vimThemeFromScheme;
  inherit (config.home-manager.users."${username}") colorscheme;
in {
  options.nixchad.neovim = {
    enable = mkEnableOption "neovim";
    plugins = mkEnableOption "neovim plugins";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.sessionVariables = {
        EDITOR = "nvim";
      };

      programs.neovim = {
        # very much inspired by this:
        # https://github.com/LunarVim/Neovim-from-scratch/
        enable = true;
        package = pkgs.neovim-nightly;
        vimAlias = true;
        vimdiffAlias = true;
        withNodeJs = cfg.plugins;

        plugins = with pkgs.vimPlugins; [
          {
            plugin = vimThemeFromScheme {scheme = colorscheme;};
            # .vim files were deprecated, this is a workaround
            # https://github.com/neovim/neovim/issues/14090#issuecomment-1177933661
            config = ''
              let g:do_legacy_filetype = 1
              colorscheme nix-${colorscheme.slug}
            '';
          }
          vim-airline
          vim-nix

          editorconfig-nvim
          indentLine
          vim-lastplace
        ] ++ optionals cfg.plugins [
          # LSP
          nvim-lspconfig

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

          telescope-nvim
          (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))

          nvim-autopairs
        ];

        extraPackages = with pkgs; optionals cfg.plugins [
          # gcc # needed for nvim-treesitter
          rnix-lsp
          terraform-ls
          nodePackages.bash-language-server
          sumneko-lua-language-server
        ];

        #${builtins.readFile ./treesitter.lua}
        extraConfig = ''
          :lua << EOF
          ${builtins.readFile ./options.lua}
          ${builtins.readFile ./keymaps.lua}
        '' + optionalString cfg.plugins ''
          ${builtins.readFile ./cmp.lua}
          ${builtins.readFile ./lsp/lsp.lua}
          ${builtins.readFile ./autopairs.lua}
        '';
      };
    };
  };
}
