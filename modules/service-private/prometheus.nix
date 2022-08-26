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
          job_name = "Prometheus";
          static_configs = [
            {
              targets = [
                "blackberry:33000" # node exporter
                "blackberry:33001" # nginx
                "blackberry:33002" # postgresql
                "blackberry:33004" # systemd exporter
                "blackberry:33100" # loki
                "blackberry:33101" # promtail

                "blueberry:33000" # node exporter
                "blueberry:33004" # systemd exporter
                "blueberry:33101" # promtail

                "virtberry:33000" # node exporter
                "virtberry:33004" # systemd exporter
                "virtberry:33101" # promtail
              ];
            }
          ];
        }
        {
          job_name = "coredns";
          static_configs = [
            {
              targets = [
                "blackberry:33003" # coredns
                "blueberry:33003" # coredns
                "virtberry:33003" # coredns
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
