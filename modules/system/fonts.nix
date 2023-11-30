{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.fonts;
in {
  options.nixchad.fonts = {
    enable = mkEnableOption "fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      fontconfig = {
        defaultFonts = {
          serif = ["FiraCode Nerd Font"];
          emoji = ["Noto Color Emoji"];
          monospace = ["FiraCode Nerd Font Mono"];
          sansSerif = ["FiraCode Nerd Font"];
        };
      };

      packages = with pkgs; [
        (nerdfonts.override {fonts = ["FiraCode"];})
        noto-fonts
        # TODO: rename to noto-fonts-color-emoji
        noto-fonts-emoji
        noto-fonts-cjk-sans
      ];
    };
  };
}
