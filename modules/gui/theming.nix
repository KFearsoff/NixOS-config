{
  config,
  lib,
  pkgs,
  username,
  ...
}: with lib; let
  cfg = config.nixchad.theming;
in {
  options.nixchad.theming = {
    enable = mkEnableOption "theming";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
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
        style.package = pkgs.libForQt5.qtstyleplugins;
        style.name = "gtk2";
      };
    };
  };
}
