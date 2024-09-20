{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.alacritty;
in
{
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
          colors.draw_bold_text_with_bright_colors = false;
        };
      };
    };
  };
}
