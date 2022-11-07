{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.cadvisor;
in {
  options.nixchad.cadvisor = {
    enable = mkEnableOption "cadvisor";
  };

  config = mkIf cfg.enable {
    services.cadvisor = {
      enable = true;
      port = 33006;
      listenAddress = "0.0.0.0";
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = map (x: "${x}:33006") config.lib.metadata.hostList;
          }
        ];
      }
    ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [33006];
  };
}
