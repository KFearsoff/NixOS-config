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
  grafanaPort = toString config.services.grafana.port;
  domain = "${hostname}.tail34ad.ts.net";
in {
  options.nixchad.grafana = {
    enable = mkEnableOption "Grafana dashboard";
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      rootUrl = "https://${domain}/grafana";
      extraOptions = {
        SERVER_SERVE_FROM_SUB_PATH = "true";
      };
      provision = {
        enable = true;
        datasources = [
          (mkDatasource "prometheus" "http://localhost:9090" {})
          (mkDatasource "loki" "http://localhost:33100" {})
        ];
        dashboards = [
          {
            options = {
              path = ./dashboards;
              foldersFromFilesStructure = true;
            };
          }
        ];
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
