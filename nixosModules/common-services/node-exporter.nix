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

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:33000"
            ];
          }
        ];
      }
    ];
  };
}
