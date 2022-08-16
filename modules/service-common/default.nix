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
    ./prometheus.nix
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
  };
}
