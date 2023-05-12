{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.invidious;
  invidiousPort = toString config.services.invidious.port;
  invidiousDomain = "invidious.nixalted.com";
in {
  options.nixchad.invidious = {
    enable = mkEnableOption "Invidious Youtube proxying service";
  };

  config = mkIf cfg.enable {
    services.invidious.enable = true;
    services.invidious.port = 32000;
    services.invidious.domain = invidiousDomain;

    services.nginx.virtualHosts."${invidiousDomain}" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://localhost:${invidiousPort}";
      };
    };
  };
}
