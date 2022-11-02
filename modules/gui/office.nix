{
  config,
  lib,
  pkgs,
  username,
...}:
with lib; let
  cfg = config.nixchad.office;
in {
  options.nixchad.office = {
    enable = mkEnableOption "office";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = [
        pkgs.libreoffice
      ];
    };

    fonts.fonts = with pkgs; [
      vistafonts
      corefonts
    ];
  };
}
