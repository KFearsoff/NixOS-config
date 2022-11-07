{
  config,
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
    ./postgres-exporter.nix
    ./blackbox-exporter.nix
    ./prometheus.nix
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

    services.nginx = {
      enable = true;

      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      statusPage = true;
    };

    services.prometheus.exporters.nginx = {
      enable = true;
      port = 33001;
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [80 443];

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/self-signed"
      ];
    };
  };
}
