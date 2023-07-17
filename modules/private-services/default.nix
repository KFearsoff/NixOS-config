{
  config,
  lib,
  servername,
  ...
}:
with lib; let
  cfg = config.nixchad.nginx;
  hostname = config.networking.hostName;
  exporter-port = "33001";
in {
  imports = [
    ./grafana
    ./invidious.nix
    ./libreddit.nix
    ./loki.nix
    ./nitter.nix
    ./postgres.nix
    ./postgres-exporter.nix
    ./blackbox-exporter.nix
    ./redis-exporter.nix
    ./prometheus.nix
    ./alertmanager
    ./vaultwarden.nix
    ./photoprism.nix
    ./tailforward.nix
  ];

  options.nixchad.nginx = {
    enable = mkEnableOption "nginx";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hostname == servername;
        message = ''
          You are trying to deploy private services on the wrong machine.
          If that's not true, change "servername" in flake.nix.
        '';
      }
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "services-nixchad@riseup.net";

      certs."nixalted.com" = {
        dnsProvider = "namecheap";
        extraDomainNames = builtins.map (x: x + ".nixalted.com") ["alertmanager" "grafana" "libreddit" "loki" "invidious" "prometheus" "nitter" "photoprism" "vaultwarden"];
        group = "nginx";
        credentialsFile = "/secrets/acme";
      };
    };

    services.nginx = {
      enable = true;

      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;

      statusPage = true;

      virtualHosts."nixalted.com" = {
        forceSSL = true;
        useACMEHost = "nixalted.com";

        extraConfig = ''
          allow 100.0.0.0/8;
          deny  all;
        '';
      };
    };

    services.prometheus.exporters.nginx = {
      enable = true;
      port = strings.toInt exporter-port;
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "nginx";
        static_configs = [
          {
            targets = [
              "localhost:${exporter-port}" # nginx
            ];
          }
        ];
      }
    ];

    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [80 443];

    nixchad.impermanence.persisted.values = [
      {
        directories =
          lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
          ["/var/lib/acme"]; # FIXME: Is this more correct than the snippet below?
        #directories = builtins.map (x: x.directory) (builtins.attrValues cfg);
      }
    ];
  };
}
