{
  config,
  lib,
  servername,
  ...
}:
with lib; let
  cfg = config.nixchad.promtail;
  hostname = config.networking.hostName;
  promtailHttpPort = "33101";
  promtailGrpcPort = "33111";
  promtailDomain = "promtail.${hostname}.me";
in {
  options.nixchad.promtail = {
    enable = mkEnableOption "Promtail log exporter";
  };

  config = mkIf cfg.enable {
    services.promtail = {
      enable = true;

      configuration = {
        server = {
          http_listen_port = strings.toInt promtailHttpPort;
          grpc_listen_port = strings.toInt promtailGrpcPort;
        };

        clients = [
          {
            url = "http://${servername}:33100/loki/api/v1/push";
          }
        ];

        scrape_configs = [
          {
            job_name = "system";
            journal = {
              max_age = "24h";
              labels = {
                job = "systemd-journal";
                host = hostname;
              };
            };
            relabel_configs = [
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };

    services.nginx.virtualHosts."${promtailDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.me/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.me/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${promtailHttpPort}";
        proxyWebsockets = true;
      };
    };
  };
}
