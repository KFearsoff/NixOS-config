{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.smartctl-exporter;
in {
  options.nixchad.smartctl-exporter = {
    enable = mkEnableOption "Prometheus smartctl exporter";

    devices = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf (cfg.enable && config.nixchad.hardware.enable) {
    services.prometheus.exporters.smartctl = {
      enable = true;
      port = 33004;
      inherit (cfg) devices;
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = map (x: "${x}:33004") config.lib.metadata.hostList;
          }
        ];
      }
    ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [33004];
    # TODO: remove once https://github.com/NixOS/nixpkgs/pull/176553 is merged
    systemd.services."prometheus-smartctl-exporter".serviceConfig.DeviceAllow = lib.mkOverride 50 [
      "block-blkext rw"
      "block-sd rw"
      "char-nvme rw"
    ];
  };
}
