# https://gitlab.com/K900/nix/-/blob/f164e274309d9a9b5d1e587f8d9adcc424a2feaf/machines/yui/grafana/blackbox_exporter.nix
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.blackbox-exporter;
  hostname = config.networking.hostName;
  blackboxPort = 33005;
  makeJobConfig = {
    name,
    module,
    targets,
  }: {
    job_name = name;
    metrics_path = "/probe";
    params.module = [module];
    static_configs = [{inherit targets;}];
    relabel_configs = [
      {
        source_labels = ["__address__"];
        target_label = "__param_target";
      }
      {
        source_labels = ["__param_target"];
        target_label = "instance";
      }
      {
        target_label = "__address__";
        replacement = "localhost:${builtins.toString blackboxPort}";
      }
    ];
  };
in {
  options.nixchad.blackbox-exporter = {
    enable = mkEnableOption "Prometheus blackbox exporter";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      exporters.blackbox = {
        enable = true;
        configFile = ./blackbox-exporter.yaml;
        port = blackboxPort;
        extraFlags = ["--log.level=debug"];
      };

      scrapeConfigs = map makeJobConfig (optionals (config.lib.metadata.hasIpv4 hostname) [
          {
            name = "blackbox";
            module = "http_2xx_v4";
            targets = [
              "https://google.com/"
              "https://api.telegram.org/"
            ];
          }
          {
            name = "ipv4";
            module = "icmp_v4";
            targets = ["google.com"];
          }
        ]
        ++ optionals (config.lib.metadata.hasIpv6 hostname) [
          {
            name = "blackbox";
            module = "http_2xx_v6";
            targets = [
              "https://google.com/"
              "https://api.telegram.org/"
            ];
          }
          {
            name = "ipv6";
            module = "icmp_v6";
            targets = ["google.com"];
          }
        ]);
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [blackboxPort];
  };
}
