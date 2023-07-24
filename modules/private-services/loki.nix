{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.loki;
  lokiHttpPort = 33100;
  lokiGrpcPort = 33110;
  alertmanagerPort = config.services.prometheus.alertmanager.port;
  lokiData = config.services.loki.dataDir;
in {
  options.nixchad.loki = {
    enable = mkEnableOption "Loki log aggregator";
  };

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;

      configuration = {
        server = {
          http_listen_port = lokiHttpPort;
          grpc_listen_port = lokiGrpcPort;
        };

        auth_enabled = false;

        common = {
          path_prefix = "${lokiData}";
          storage.filesystem = {
            chunks_directory = "${lokiData}/chunks";
            rules_directory = "${lokiData}/rules";
          };
          replication_factor = 1;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
        };

        schema_config = {
          configs = [
            {
              from = "2022-05-15";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        ruler.alertmanager_url = alertmanagerPort;
      };
    };

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "loki";
        static_configs = [
          {
            targets = [
              "localhost:${toString lokiHttpPort}"
            ];
          }
        ];
      }
    ];

    nixchad.impermanence.persisted.values = [
      {
        directories =
          lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
          [
            {
              directory = config.services.loki.dataDir;
              user = "loki";
              group = "loki";
            }
          ];
      }
    ];

    nixchad.nginx.vhosts."loki" = {
      port = lokiHttpPort;
    };
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [lokiHttpPort lokiGrpcPort];
  };
}
