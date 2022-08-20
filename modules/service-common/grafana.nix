{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.grafana;
  server = "blackberry";
  hostname = config.networking.hostName;
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
          {
            name = "${server}";
            type = "prometheus";
            url = "http://${server}:9090";
          }
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
