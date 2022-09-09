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
  grafanaDomain = "grafana.${hostname}.me";
in {
  options.nixchad.grafana = {
    enable = mkEnableOption "Grafana dashboard";
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      domain = grafanaDomain;
      provision = {
        enable = true;
        datasources = [
          (mkDatasource "prometheus" "http://localhost:9090" {})
          (mkDatasource "loki" "http://localhost:33100" {})
        ];
      };
    };

    services.nginx.virtualHosts."${grafanaDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/${grafanaDomain}/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/${grafanaDomain}/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${grafanaPort}";
        proxyWebsockets = true;
      };
    };
    networking.extraHosts = ''
      127.0.0.1 ${grafanaDomain}
    '';

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "${config.services.grafana.dataDir}"
      ];
    };
  };
}
