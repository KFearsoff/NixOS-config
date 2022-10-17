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
                "blackberry:33000" # node exporter
                "blackberry:33001" # nginx
                "blackberry:33002" # postgresql
                "blackberry:33004" # smartctl exporter
                "blackberry:33006" # cadvisor
                "blackberry:33100" # loki
                "blackberry:33101" # promtail

                "blueberry:33000" # node exporter
                "blueberry:33004" # smartctl exporter
                "blueberry:33006" # cadvisor
                "blueberry:33101" # promtail

                "virtberry:33000" # node exporter
                "virtberry:33004" # smartctl exporter
                "virtberry:33006" # cadvisor
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
