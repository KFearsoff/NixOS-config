{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.prometheus;
  nodePort = toString config.services.prometheus.exporters.node.port;
  hostname = config.networking.hostName;
  prometheusPort = toString config.services.prometheus.port;
  prometheusDomain = "prometheus.${hostname}.me";
in {
  options.nixchad.prometheus = {
    enable = mkEnableOption "Prometheus monitoring";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "blackberry";
          static_configs = [
            {
              targets = [
                "blackberry:33000" # node exporter
                "blackberry:33001" # nginx
                "blackberry:33002" # postgresql
                "blackberry:33004" # systemd exporter
              ];
            }
          ];
        }
      ];
    };

    services.nginx.virtualHosts."${prometheusDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/${prometheusDomain}/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/${prometheusDomain}/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${prometheusPort}";
        proxyWebsockets = true;
      };
    };
    networking.extraHosts = ''
      127.0.0.1 ${prometheusDomain}
    '';

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        ("/var/lib/" + "${config.services.prometheus.stateDir}")
      ];
    };
  };
}
