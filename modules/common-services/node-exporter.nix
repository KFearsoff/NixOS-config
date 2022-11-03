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

    # remove once https://github.com/NixOS/nixpkgs/pull/198638 is merged
    systemd.services.prometheus-node-exporter.serviceConfig.RestrictAddressFamilies = [
      "AF_NETLINK"
    ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [33000];
  };
}
