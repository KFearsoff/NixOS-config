{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.redis-exporter;
  port = "33007";
in {
  options.nixchad.postgres-exporter = {
    enable = mkEnableOption "Prometheus Redis exporter";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.redis = {
      enable = true;
      port = strings.toInt port;
    };

    services.prometheus.scrapeConfigs = [
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
