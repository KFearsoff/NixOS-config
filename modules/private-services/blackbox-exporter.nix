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

  makeJobConfig = module: {
    job_name = module;
    metrics_path = "/probe";
    params.module = [module];

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
        replacement = "localhost:${toString blackboxPort}";
      }
    ];

    static_configs = [
      {
        targets = let
          preTargetsIcmp =
            [
              "google.com"
              "api.telegram.org"
            ]
            ++ map (x: "${x}.tail34ad.ts.net") config.lib.metadata.hostList;
          preTargetsHttps =
            [
              "google.com"
            ]
            ++ map (x: "${x}.tail34ad.ts.net") config.lib.metadata.hostList;
        in
          if (module == "icmp_v4" || module == "icmp_v6")
          then preTargetsIcmp ++ map (x: "${x}.tail34ad.ts.net") config.lib.metadata.phoneList
          else map (x: "https://${x}") preTargetsHttps;
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
          "icmp_v4"
          "http_2xx_v4"
        ]
        ++ optionals (config.lib.metadata.hasIpv6 hostname) [
          "icmp_v6"
          "http_2xx_v6"
        ]);
    };
  };
}
