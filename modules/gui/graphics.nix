{
  config,
  lib,
  pkgs,
  username,
...}:
with lib; let
  cfg = config.nixchad.graphics;
in {
  options.nixchad.graphics = {
    enable = mkEnableOption "graphics";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
      home.packages = [
        pkgs.gimp
      ];
    };
  };
}
