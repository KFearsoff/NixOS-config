{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.loki;
  lokiHttpPort = 33100;
  lokiGrpcPort = 33110;
  alertmanagerPort = config.services.prometheus.alertmanager.port;
  lokiData = config.services.loki.dataDir;
in
{
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

        compactor = {
          working_directory = "${lokiData}/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "1s";
          retention_delete_worker_count = 150;
          delete_request_store = "filesystem";
        };

        limits_config.retention_period = "1w";

        schema_config = {
          configs = [
            {
              from = "2022-07-25";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v12";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
            {
              from = "2024-05-02";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
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

    nixchad = {
      grafana-agent.metrics_scrape_configs = [
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

      impermanence.persisted.values = [
        {
          directories =
            lib.mkIf
              (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
              [
                {
                  directory = config.services.loki.dataDir;
                  user = "loki";
                  group = "loki";
                }
              ];
        }
      ];
    };
  };
}
