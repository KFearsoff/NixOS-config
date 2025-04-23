{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.alloy;
in
{
  options.nixchad.alloy = {
    enable = mkEnableOption "Alloy, universal observability exporter";
  };

  config = mkIf cfg.enable {
    services.alloy.enable = true;

    systemd.services.alloy = {
      after = [
        "tailscaled.service"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
    };

    environment.etc."alloy/config.alloy".source = ./common.alloy;
  };
}
