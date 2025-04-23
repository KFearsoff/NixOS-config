{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.postgres-exporter;
  port = "33002";
in
{
  options.nixchad.postgres-exporter = {
    enable = mkEnableOption "Prometheus Postgres exporter";
  };

  config = mkIf cfg.enable {
    services = {
      prometheus.exporters.postgres = {
        enable = true;
        port = strings.toInt port;
        runAsLocalSuperUser = true;
        extraFlags = [
          "--auto-discover-databases"
          "--collector.long_running_transactions"
          "--collector.stat_activity_autovacuum"
          "--collector.stat_statements"
        ];
      };

      pgscv = {
        enable = true;
        logLevel = "debug";
        settings = {
          services.postgres = {
            service_type = "postgres";
            conninfo = "postgres://";
          };
        };
      };
    };

    environment.etc."alloy/postgres.alloy".text = ''
      scrape_url "pgscv" {
        name = "pgscv"
        url = "localhost:9890"
      }

      // FIXME: Can't use the build-in postgres_exporter
      // See: https://github.com/grafana/alloy/issues/3181
      scrape_url "postgres" {
        name = "postgres"
        url = "localhost:${port}
      }
    '';
  };
}
