{
  config,
  lib,
  servername,
  ...
}:
with lib; let
  cfg = config.nixchad.grafana-agent;
  hostname = config.networking.hostName;
in {
  options.nixchad.grafana-agent = {
    enable = mkEnableOption "Grafana Agent, universal observability exporter";
  };

  config = mkIf cfg.enable {
    services.grafana-agent = {
      enable = true;
      settings = {
        logs = {
          configs = [
            {
              name = "systemd-journal";
              positions.filename = "\${STATE_DIRECTORY}/positions.yaml";
              clients = [
                {
                  url = "http://${servername}:33100/loki/api/v1/push";
                }
              ];

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
                      source_labels = ["__journal__systemd_unit"];
                      target_label = "unit";
                    }
                  ];
                }
              ];
            }
          ];
        };
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [12345];
  };
}
