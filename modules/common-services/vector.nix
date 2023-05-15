{
  config,
  lib,
  servername,
  ...
}:
with lib; let
  cfg = config.nixchad.vector;
in {
  options.nixchad.vector = {
    enable = mkEnableOption "vector log exporter";
  };

  config = mkIf cfg.enable {
    services.vector = {
      enable = true;
      journaldAccess = true;

      settings = {
        sources = {
          journald.type = "journald";
          vector_metrics.type = "internal_metrics";
        };

        sinks.loki = {
          inputs = ["journald"];
          type = "loki";
          endpoint = "http://${servername}:33100";
          encoding.codec = "raw_message";
          labels = {
            host = "{{ .host }}";
            job = "systemd-journal";
            unit = "{{ ._SYSTEMD_UNIT }}";
          };
        };

        sinks.prometheus = {
          type = "prometheus_exporter";
          address = "0.0.0.0:33101";
          inputs = ["vector_metrics"];
        };
      };
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "vector";
        static_configs = [
          {
            targets = map (x: "${x}:33101") config.lib.metadata.hostList;
          }
        ];
      }
    ];

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [33101];
  };
}
