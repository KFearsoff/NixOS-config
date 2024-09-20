{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.office;
in
{
  options.nixchad.office = {
    enable = mkEnableOption "office";
  };

  config = mkIf cfg.enable {
    hm = {
      home.packages = [
        pkgs.libreoffice
      ];
    };

    fonts.packages = with pkgs; [
      vistafonts
      corefonts
    ];
  };
}
