{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.loki;
  lokiHttpPort = "33100";
  lokiGrpcPort = "33110";
  lokiDomain = "loki.nixalted.com";
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
          http_listen_port = strings.toInt lokiHttpPort;
          grpc_listen_port = strings.toInt lokiGrpcPort;
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

    services.prometheus.scrapeConfigs = [
      {
        job_name = "loki";
        static_configs = [
          {
            targets = [
              "localhost:${lokiHttpPort}"
            ];
          }
        ];
      }
    ];

    services.nginx.virtualHosts."${lokiDomain}" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://localhost:${lokiHttpPort}";
        proxyWebsockets = true;
      };
    };
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [33100 33110];
  };
}
