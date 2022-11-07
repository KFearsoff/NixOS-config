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
  prometheusDomain = "prometheus.${hostname}.box";
in {
  options.nixchad.prometheus = {
    enable = mkEnableOption "Prometheus monitoring";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      # The default of 1m is pretty stupid. It breaks Grafana's $__rate_interval.
      # Explanation can be found here:
      # https://github.com/rfrail3/grafana-dashboards/issues/72#issuecomment-880484961
      globalConfig.scrape_interval = "15s";
      scrapeConfigs = [
        {
          job_name = "Prometheus";
          static_configs = [
            {
              targets = [
                "localhost:33001" # nginx
                "localhost:33002" # postgresql
                "localhost:33100" # loki
              ];
            }
          ];
        }
      ];
    };

    services.nginx.virtualHosts."${prometheusDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.box/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.box/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${prometheusPort}";
        proxyWebsockets = true;
      };
    };

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        ("/var/lib/" + "${config.services.prometheus.stateDir}")
      ];
    };
  };
}
