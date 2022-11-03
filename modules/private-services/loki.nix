{
  config,
  lib,
  servername,
  ...
}:
with lib; let
  cfg = config.nixchad.loki;
  hostname = config.networking.hostName;
  lokiHttpPort = "33100";
  lokiGrpcPort = "33110";
  lokiDomain = "loki.${hostname}.box";
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

    # It doesn't seem like Libreddit allows subpaths. Wait for this:
    # https://github.com/tailscale/tailscale/issues/1235#issuecomment-927002943
    services.nginx.virtualHosts."${lokiDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.box/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.box/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${lokiHttpPort}";
        proxyWebsockets = true;
      };
    };
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [33100 33110];

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "${lokiData}"
      ];
    };
  };
}
