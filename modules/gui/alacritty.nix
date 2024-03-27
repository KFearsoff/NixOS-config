{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.alacritty;
  inherit (config.hm) colorScheme;
in {
  options.nixchad.alacritty = {
    enable = mkEnableOption "alacritty";
  };

  config = mkIf cfg.enable {
    hm = {
      terminal = {
        enable = true;
        package = pkgs.alacritty;
        windowName = "Alacritty";
      };

      programs.alacritty = {
        enable = true;

        settings = {
          font.size = 14.0;
          window.opacity = 0.85;

          colors = {
            primary = {
              background = "0x${colorScheme.palette.base00}";
              foreground = "0x${colorScheme.palette.base05}";
            };

            cursor = {
              text = "0x${colorScheme.palette.base00}";
              cursor = "0x${colorScheme.palette.base05}";
            };

            normal = {
              black = "0x${colorScheme.palette.base00}";
              red = "0x${colorScheme.palette.base08}";
              green = "0x${colorScheme.palette.base0B}";
              yellow = "0x${colorScheme.palette.base0A}";
              blue = "0x${colorScheme.palette.base0D}";
              magenta = "0x${colorScheme.palette.base0E}";
              cyan = "0x${colorScheme.palette.base0C}";
              white = "0x${colorScheme.palette.base05}";
            };

            bright = {
              black = "0x${colorScheme.palette.base03}";
              red = "0x${colorScheme.palette.base08}";
              green = "0x${colorScheme.palette.base0B}";
              yellow = "0x${colorScheme.palette.base0A}";
              blue = "0x${colorScheme.palette.base0D}";
              magenta = "0x${colorScheme.palette.base0E}";
              cyan = "0x${colorScheme.palette.base0C}";
              white = "0x${colorScheme.palette.base07}";
            };

            indexed_colors = [
              {
                index = 16;
                color = "0x${colorScheme.palette.base09}";
              }
              {
                index = 17;
                color = "0x${colorScheme.palette.base0F}";
              }
              {
                index = 18;
                color = "0x${colorScheme.palette.base01}";
              }
              {
                index = 19;
                color = "0x${colorScheme.palette.base02}";
              }
              {
                index = 20;
                color = "0x${colorScheme.palette.base04}";
              }
              {
                index = 21;
                color = "0x${colorScheme.palette.base06}";
              }
            ];

            draw_bold_text_with_bright_colors = false;
          };
        };
      };
    };
  };
}
