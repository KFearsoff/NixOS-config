{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.nitter;
  nitterPort = toString config.services.nitter.server.port;
  nitterDomain = "nitter.nixalted.com";
in {
  options.nixchad.nitter = {
    enable = mkEnableOption "Nitter Twitter proxying service";
  };

  config = mkIf cfg.enable {
    services.nitter.enable = true;
    services.nitter.server.port = 32002;
    services.nitter.server.hostname = nitterDomain;

    services.nginx.virtualHosts."${nitterDomain}" = {
      forceSSL = true;
      useACMEHost = "nixalted.com";

      locations."/" = {
        proxyPass = "http://localhost:${nitterPort}";
      };

      extraConfig = ''
        allow 100.100.100.100/8;
        deny  all;
      '';
    };
  };
}
