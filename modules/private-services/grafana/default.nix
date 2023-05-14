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
  grafanaPort = toString config.services.grafana.settings.server.http_port;
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

    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = "nixalted.com";

      locations."/" = {
        proxyPass = "http://localhost:${grafanaPort}";
        proxyWebsockets = true;
      };

      extraConfig = ''
        allow 100.100.100.100/8;
        deny  all;
      '';
    };
  };
}
