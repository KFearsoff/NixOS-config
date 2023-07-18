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

        database = {
          type = "postgres";
          user = "grafana";
          host = "/run/postgresql";
          name = "grafana";
          password = "";
        };
      };

      provision = {
        enable = true;

        datasources.settings = {
          datasources = [
            (mkDatasource "prometheus" "http://localhost:9090" {})
            (mkDatasource "loki" "http://localhost:33100" {})
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
          ensurePermissions."DATABASE grafana" = "ALL PRIVILEGES";
        }
      ];
    };

    nixchad.impermanence.persisted.values = [
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

    nixchad.nginx.vhosts."grafana" = {
      websockets = true;
      port = grafanaPort;
    };
  };
}
