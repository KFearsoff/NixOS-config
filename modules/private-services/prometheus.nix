{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.prometheus;
  prometheusPort = config.services.prometheus.port;
in {
  options.nixchad.prometheus = {
    enable = mkEnableOption "Prometheus monitoring";
  };

  config = mkIf cfg.enable {
    nixchad.alertmanager.enable = mkDefault true;

    services.prometheus = {
      enable = true;
      globalConfig = {
        # The default of 1m is pretty stupid. It breaks Grafana's $__rate_interval.
        # Explanation can be found here:
        # https://github.com/rfrail3/grafana-dashboards/issues/72#issuecomment-880484961
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
      webExternalUrl = "https://prometheus.nixalted.com";
      extraFlags = ["--web.enable-remote-write-receiver"];
      enableReload = true;
    };

    nixchad.impermanence.persisted.values = [
      {
        directories =
          lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
          [("/var/lib/" + config.services.prometheus.stateDir)];
      }
    ];

    nixchad.nginx.vhosts."prometheus" = {
      port = prometheusPort;
    };

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [
              "localhost:${toString prometheusPort}"
            ];
          }
        ];
      }
    ];
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [9090];
  };
}
