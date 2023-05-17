{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.postgres-exporter;
  port = "33002";
in {
  options.nixchad.postgres-exporter = {
    enable = mkEnableOption "Prometheus Postgres exporter";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.postgres = {
      enable = true;
      port = strings.toInt port;
      dataSourceName = "user=postgres-exporter database=postgres host=/run/postgresql sslmode=disable";
      extraFlags = ["--auto-discover-databases"];
    };

    services.postgresql.ensureUsers = [{name = "postgres-exporter";}];

    services.prometheus.scrapeConfigs = [
      {
        job_name = "postgres";
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
