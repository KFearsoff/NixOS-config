{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.theming;
in {
  options.nixchad.theming = {
    enable = mkEnableOption "theming";
  };

  config = mkIf cfg.enable {
    hm = {
      gtk = {
        enable = true;
        iconTheme.package = pkgs.papirus-icon-theme;
        iconTheme.name = "Papirus-Dark";
        theme.name = "Dracula";
        theme.package = pkgs.dracula-theme;
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
        gtk4.extraConfig = {
          color-scheme = "prefer-dark";
        };
      };
      qt = {
        enable = true;
        platformTheme = "gtk";
      };
    };
  };
}
