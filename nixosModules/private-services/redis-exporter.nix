{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.redis-exporter;
  port = "33007";
in {
  options.nixchad.redis-exporter = {
    enable = mkEnableOption "Prometheus Redis exporter";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.redis = {
      enable = true;
      port = strings.toInt port;
    };

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "redis";
        static_configs = [
          {
            targets = [
              "localhost:${port}"
            ];
          }
        ];
      }
    ];
  };
}
