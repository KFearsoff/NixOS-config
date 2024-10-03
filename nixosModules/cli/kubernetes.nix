{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.kubernetes;
in
{
  options.nixchad.kubernetes = {
    enable = mkEnableOption "kubernetes";
  };

  config = mkIf cfg.enable {
    hm = {
      home = {
        packages = with pkgs; [
          kubectl
          kubernetes-helm
        ];
      };
    };
  };
}
