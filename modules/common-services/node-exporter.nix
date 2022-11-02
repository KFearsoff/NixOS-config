{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.node-exporter;
in {
  options.nixchad.node-exporter = {
    enable = mkEnableOption "Prometheus node exporter";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = ["processes" "systemd"];
      port = 33000;
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [33000];
  };
}