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
        EDITOR = "nvim";
      };

      programs.neovim = {
        enable = true;
        vimAlias = true;
        vimdiffAlias = true;
        # FIXME: remove once updated HM stateVersion to 26.05
        withPython3 = false;
        withRuby = false;

        extraPackages = with pkgs; [
          gcc # needed for nvim-treesitter
          tree-sitter

          # HTML, CSS, JSON
          vscode-langservers-extracted

          # LazyVim defaults
          stylua
          shfmt

          # Markdown extra
          markdownlint-cli2
          marksman

          # JSON and YAML extras
          yaml-language-server

          # Custom
          editorconfig-checker
          shellcheck
          nixd
        ];
      };

      xdg.configFile."nvim" = {
        recursive = true;
        source = ./config;
      };
    };
  };
}
