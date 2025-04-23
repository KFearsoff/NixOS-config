{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.smartctl-exporter;
in
{
  options.nixchad.smartctl-exporter = {
    enable = mkEnableOption "Prometheus smartctl exporter";

    devices = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf (cfg.enable && config.nixchad.hardware.enable) {
    services.prometheus.exporters.smartctl = {
      enable = true;
      port = 33004;
      inherit (cfg) devices;
    };

    environment.etc."alloy/smartctl.alloy".text = ''
      scrape_url "smartctl" {
        name = "smartctl"
        url = "localhost:33004"
      }
    '';
  };
}
