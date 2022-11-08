{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.grafana;
  hostname = config.networking.hostName;
  mkDatasource = type: url: extraConfig:
    {
      name = type;
      inherit type;
      uid = "provisioned_uid_${type}";
      inherit url;
    }
    // extraConfig;
  grafanaPort = toString config.services.grafana.settings.server.http_port;
  domain = "${hostname}.tail34ad.ts.net";
in {
  options.nixchad.grafana = {
    enable = mkEnableOption "Grafana dashboard";
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings.server = {
        root_url = "https://${domain}/grafana";
        serve_from_sub_path = true;
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

    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/${domain}.crt";
      sslCertificateKey = "/var/lib/self-signed/${domain}.key";

      locations."/grafana" = {
        proxyPass = "http://localhost:${grafanaPort}";
        proxyWebsockets = true;
      };
    };

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "${config.services.grafana.dataDir}"
      ];
    };
  };
}
