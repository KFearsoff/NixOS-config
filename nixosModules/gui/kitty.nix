{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.kitty;
  inherit (config.hm) colorScheme;
in {
  options.nixchad.kitty = {
    enable = mkEnableOption "kitty";
  };

  config = mkIf cfg.enable {
    hm = {
      home.sessionVariables = mkIf config.services.xserver.enable {
        TERM = "xterm-256color";
      };

      terminal = {
        enable = true;
        package = pkgs.kitty;
      };

      home.shellAliases = {
        ssh = "TERM=\"xterm-256color\" ${pkgs.kitty}/bin/kitty +kitten ssh ";
      };

      programs.kitty = {
        enable = true;
        font = {
          name = "Iosevka Term Nerd Font Complete Mono";
          size = 14;
        };
        settings = {
          disable_ligatures = "cursor";
          cursor_blink_interval = 0;
          enable_audio_bell = "no";
          window_alert_on_bell = "no";
          shell_integration = "enabled";

          bold_font = "Iosevka Term Bold Nerd Font Complete Mono";
          italic_font = "Iosevka Term Italic Nerd Font Complete Mono";
          bold_italic_font = "Iosevka Term Bold Italic Nerd Font Complete Mono";

          background = "#${colorScheme.palette.base00}";
          foreground = "#${colorScheme.palette.base05}";

          selection_background = "#${colorScheme.palette.base05}";
          selection_foreground = "#${colorScheme.palette.base00}";

          url_color = "#${colorScheme.palette.base04}";
          cursor = "#${colorScheme.palette.base05}";
          active_border_color = "#${colorScheme.palette.base03}";
          inactive_border_color = "#${colorScheme.palette.base01}";
          active_tab_background = "#${colorScheme.palette.base00}";
          active_tab_foreground = "#${colorScheme.palette.base05}";
          inactive_tab_background = "#${colorScheme.palette.base01}";
          inactive_tab_foreground = "#${colorScheme.palette.base04}";
          tab_bar_background = "#${colorScheme.palette.base01}";

          color0 = "#${colorScheme.palette.base00}";
          color1 = "#${colorScheme.palette.base08}";
          color2 = "#${colorScheme.palette.base0B}";
          color3 = "#${colorScheme.palette.base0A}";
          color4 = "#${colorScheme.palette.base0D}";
          color5 = "#${colorScheme.palette.base0E}";
          color6 = "#${colorScheme.palette.base0C}";
          color7 = "#${colorScheme.palette.base05}";

          color8 = "#${colorScheme.palette.base03}";
          color9 = "#${colorScheme.palette.base08}";
          color10 = "#${colorScheme.palette.base0B}";
          color11 = "#${colorScheme.palette.base0A}";
          color12 = "#${colorScheme.palette.base0D}";
          color13 = "#${colorScheme.palette.base0E}";
          color14 = "#${colorScheme.palette.base0C}";
          color15 = "#${colorScheme.palette.base07}";

          color16 = "#${colorScheme.palette.base09}";
          color17 = "#${colorScheme.palette.base0F}";
          color18 = "#${colorScheme.palette.base01}";
          color19 = "#${colorScheme.palette.base02}";
          color20 = "#${colorScheme.palette.base04}";
          color21 = "#${colorScheme.palette.base06}";
        };
      };
    };
  };
}
