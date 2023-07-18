{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.invidious;
  invidiousPort = config.services.invidious.port;
  invidiousDomain = "invidious.nixalted.com";
in {
  options.nixchad.invidious = {
    enable = mkEnableOption "Invidious Youtube proxying service";
  };

  config = mkIf cfg.enable {
    services.invidious.enable = true;
    services.invidious.port = 32000;
    services.invidious.domain = invidiousDomain;

    nixchad.nginx.vhosts."invidious" = {
      port = invidiousPort;
    };
  };
}
