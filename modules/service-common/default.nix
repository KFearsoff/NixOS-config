{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.nginx;
in {
  imports = [
    ./grafana.nix
    ./invidious.nix
    ./libreddit.nix
    ./nitter.nix
    ./prometheus.nix
    ./vaultwarden.nix
  ];

  options.nixchad.nginx = {
    enable = mkEnableOption "nginx";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      statusPage = true;
    };

    networking.firewall.allowedTCPPorts = [80 443];

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/self-signed"
      ];
    };
  };
}
