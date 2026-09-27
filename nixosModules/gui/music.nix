{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.music;
in
{
  options.nixchad.music = {
    enable = mkEnableOption "music";
  };

  config = mkIf cfg.enable {
    hm = {
      home.packages = with pkgs; [
        nicotine-plus
        tauon
      ];
    };
  };
}
