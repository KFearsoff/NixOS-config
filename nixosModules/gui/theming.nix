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
    hm = {config, ...}: {
      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        theme = {
          name = "Dracula";
          package = pkgs.dracula-theme;
        };
        gtk2 = {
          configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
          extraConfig = ''
            gtk-alternative-button-order = 1
          '';
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
          gtk-decoration-layout = "icon:minimize,maximize,close";
        };
        gtk4.extraConfig = {
          color-scheme = "prefer-dark";
          gtk-decoration-layout = "icon:minimize,maximize,close";
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk";
      };

      home.pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
        gtk.enable = true;
        x11.enable = true;
      };
    };
  };
}
