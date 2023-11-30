{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.office;
in {
  options.nixchad.office = {
    enable = mkEnableOption "office";
  };

  config = mkIf cfg.enable {
    hm = {
      home.packages = [
        pkgs.libreoffice
      ];
    };

    # TODO: rename to fonts.packages
    fonts.fonts = with pkgs; [
      vistafonts
      corefonts
    ];
  };
}
