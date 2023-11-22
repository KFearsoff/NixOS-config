{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.grafana;
  mkDatasource = type: url: extraConfig:
    {
      name = type;
      inherit type;
      uid = "provisioned_uid_${type}";
      inherit url;
    }
    // extraConfig;
  grafanaPort = config.services.grafana.settings.server.http_port;
  domain = "grafana.nixalted.com";
in {
  options.nixchad.grafana = {
    enable = mkEnableOption "Grafana dashboard";
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server.root_url = "https://${domain}";
        analytics.reporting_enabled = false;

        database = {
          type = "postgres";
          user = "grafana";
          host = "/run/postgresql";
          name = "grafana";
          password = "";
        };

        "tracing.opentelemetry.otlp".address = "localhost:4317";
      };

      provision = {
        enable = true;

        datasources.settings = {
          datasources = [
            (mkDatasource "prometheus" "http://localhost:9090" {})
            (mkDatasource "loki" "http://localhost:33100" {})
            (mkDatasource "tempo" "http://localhost:33102" {})
          ];
        };

        dashboards.settings = {
          providers = [
            {
              options = {
                path = ./dashboards;
                foldersFromFilesStructure = true;
              };
            }
          ];
        };
      };
    };

    services.postgresql = {
      ensureDatabases = ["grafana"];
      ensureUsers = [
        {
          name = "grafana";
          ensureDBOwnership = true;
        }
      ];
    };
    nixchad = {
      impermanence.persisted.values = [
        {
          directories =
            lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
            [
              {
                directory = config.services.grafana.dataDir;
                user = "grafana";
                group = "grafana";
              }
            ];
        }
      ];

      nginx.vhosts."grafana" = {
        websockets = true;
        port = grafanaPort;
      };

      grafana-agent.metrics_scrape_configs = [
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [
                "localhost:${toString grafanaPort}"
              ];
            }
          ];
        }
      ];
    };
  };
}
