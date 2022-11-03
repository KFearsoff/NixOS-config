{
  config,
  lib,
  pkgs,
  username,
  ...
}: with lib; let
  cfg = config.nixchad.kitty;
  inherit (config.home-manager.users."${username}") colorscheme;
in {
  options.nixchad.kitty = {
    enable = mkEnableOption "kitty";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.sessionVariables = mkIf (config.services.xserver.enable) {
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

          background = "#${colorscheme.colors.base00}";
          foreground = "#${colorscheme.colors.base05}";

          selection_background = "#${colorscheme.colors.base05}";
          selection_foreground = "#${colorscheme.colors.base00}";

          url_color = "#${colorscheme.colors.base04}";
          cursor = "#${colorscheme.colors.base05}";
          active_border_color = "#${colorscheme.colors.base03}";
          inactive_border_color = "#${colorscheme.colors.base01}";
          active_tab_background = "#${colorscheme.colors.base00}";
          active_tab_foreground = "#${colorscheme.colors.base05}";
          inactive_tab_background = "#${colorscheme.colors.base01}";
          inactive_tab_foreground = "#${colorscheme.colors.base04}";
          tab_bar_background = "#${colorscheme.colors.base01}";

          color0 = "#${colorscheme.colors.base00}";
          color1 = "#${colorscheme.colors.base08}";
          color2 = "#${colorscheme.colors.base0B}";
          color3 = "#${colorscheme.colors.base0A}";
          color4 = "#${colorscheme.colors.base0D}";
          color5 = "#${colorscheme.colors.base0E}";
          color6 = "#${colorscheme.colors.base0C}";
          color7 = "#${colorscheme.colors.base05}";

          color8 = "#${colorscheme.colors.base03}";
          color9 = "#${colorscheme.colors.base08}";
          color10 = "#${colorscheme.colors.base0B}";
          color11 = "#${colorscheme.colors.base0A}";
          color12 = "#${colorscheme.colors.base0D}";
          color13 = "#${colorscheme.colors.base0E}";
          color14 = "#${colorscheme.colors.base0C}";
          color15 = "#${colorscheme.colors.base07}";

          color16 = "#${colorscheme.colors.base09}";
          color17 = "#${colorscheme.colors.base0F}";
          color18 = "#${colorscheme.colors.base01}";
          color19 = "#${colorscheme.colors.base02}";
          color20 = "#${colorscheme.colors.base04}";
          color21 = "#${colorscheme.colors.base06}";
        };
      };
    };
  };
}
