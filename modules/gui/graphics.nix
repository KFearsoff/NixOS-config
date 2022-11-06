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
    hm = {
      home.packages = [
        pkgs.gimp
      ];
    };
  };
}
