{
  config,
  lib,
  servername,
  ...
}:
with lib;
let
  cfg = config.nixchad.grafana-agent;
  hostname = config.networking.hostName;
in
{
  options.nixchad.grafana-agent = {
    enable = mkEnableOption "Grafana Agent, universal observability exporter";
    metrics_scrape_configs = mkOption {
      type = types.listOf (types.attrsOf types.anything);
    };
  };

  config = mkIf cfg.enable {
    services.grafana-agent = {
      enable = true;
      settings = {
        integrations = {
          node_exporter.enabled = false;
        };

        logs = {
          global.clients = [ { url = "http://${servername}:33100/loki/api/v1/push"; } ];
          configs = [
            {
              name = "default";
              positions.filename = "\${STATE_DIRECTORY}/positions";
              scrape_configs = [
                {
                  job_name = "systemd-journal";
                  journal = {
                    max_age = "12h";
                    labels = {
                      job = "systemd-journal";
                      host = hostname;
                    };
                  };
                  relabel_configs = [
                    {
                      source_labels = [ "__journal__systemd_unit" ];
                      target_label = "unit";
                    }
                  ];
                }
              ];
            }
          ];
        };

        metrics = {
          global = {
            # The default of 1m is pretty stupid. It breaks Grafana's $__rate_interval.
            # Explanation can be found here:
            # https://github.com/rfrail3/grafana-dashboards/issues/72#issuecomment-880484961
            scrape_interval = "15s";
            evaluation_interval = "15s";
            remote_write = [
              {
                url = "http://${servername}:9090/api/v1/write";
              }
            ];
          };

          configs = [
            {
              name = "default";
              scrape_configs = builtins.map (
                job:
                job
                // {
                  relabel_configs = [
                    {
                      source_labels = [ "__address__" ];
                      regex = "(.*):(.*)"; # The regex to match the whole address and separate it into two groups: before and after the colon
                      replacement = "${config.networking.hostName}:\${2}"; # Keep the colon and port number and replace the first part with hostname
                      target_label = "instance";
                    }
                  ];
                }
              ) cfg.metrics_scrape_configs;
            }
          ];
        };

        traces = {
          configs = [
            {
              name = "default";
              receivers = {
                otlp = {
                  protocols = {
                    grpc.endpoint = "0.0.0.0:4317";
                    http.endpoint = "0.0.0.0:4318";
                  };
                };
              };
              remote_write = [
                {
                  endpoint = "${servername}:33113";
                  insecure = true;
                }
              ];
              batch = {
                timeout = "10s";
                send_batch_size = "10000";
              };
            }
          ];
        };
      };
    };
  };
}
