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
    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        openFirewall = true;
        #firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
      };
    };

    services.prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = ["${hostname}:${nodePort}"];
            }
          ];
          scrape_interval = "15s";
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
