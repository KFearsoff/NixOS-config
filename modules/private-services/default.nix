{
  config,
  pkgs,
  lib,
  servername,
  ...
}:
with lib; let
  cfg = config.nixchad.nginx;
  hostname = config.networking.hostName;
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
    ./prometheus.nix
    ./alertmanager
    ./vaultwarden.nix
    ./photoprism.nix
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
    };

    services.prometheus.exporters.nginx = {
      enable = true;
      port = 33001;
    };

    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [80 443];

    systemd.services."tailscale.nginx-auth" = {
      after = ["nginx.service"];
      wants = ["nginx.service"];
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${pkgs.tailscale}/bin/nginx-auth";
        DynamicUser = true;
      };
    };

    systemd.sockets."tailscale.nginx-auth" = {
      partOf = ["tailscale.nginx-auth.service"];
      wantedBy = ["sockets.target"];
      listenStreams = ["/run/tailscale/tailscale.nginx-auth.sock"];
    };
  };
}
