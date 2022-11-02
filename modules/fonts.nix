{
  config,
  lib,
  pkgs,
...}:
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
          serif = ["Iosevka"];
          emoji = ["Iosevka"];
          monospace = ["Iosevka"];
          sansSerif = ["Iosevka"];
        };
      };

      fonts = with pkgs; [
        (nerdfonts.override {fonts = ["Iosevka" "Noto"];})
        vistafonts
        corefonts
      ];
    };
  };
}
