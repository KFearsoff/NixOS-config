{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.prometheus;
  prometheusPort = toString config.services.prometheus.port;
  prometheusDomain = "prometheus.nixalted.com";
in {
  options.nixchad.prometheus = {
    enable = mkEnableOption "Prometheus monitoring";
  };

  config = mkIf cfg.enable {
    nixchad.alertmanager.enable = mkDefault true;

    services.prometheus = {
      enable = true;
      # The default of 1m is pretty stupid. It breaks Grafana's $__rate_interval.
      # Explanation can be found here:
      # https://github.com/rfrail3/grafana-dashboards/issues/72#issuecomment-880484961
      globalConfig.scrape_interval = "15s";
      scrapeConfigs = [
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [
                "localhost:${prometheusPort}"
              ];
            }
          ];
        }
        {
          job_name = "private-services";
          static_configs = [
            {
              targets = [
                "localhost:33001" # nginx
                "localhost:33002" # postgresql
              ];
            }
          ];
        }
      ];
    };

    services.nginx.virtualHosts."${prometheusDomain}" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://localhost:${prometheusPort}";
        proxyWebsockets = true;
      };
    };
  };
}
