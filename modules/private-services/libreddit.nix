{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.libreddit;
  libredditPort = toString config.services.libreddit.port;
  libredditDomain = "libreddit.nixalted.com";
in {
  options.nixchad.libreddit = {
    enable = mkEnableOption "Libreddit Reddit proxying service";
  };

  config = mkIf cfg.enable {
    services.libreddit.enable = true;
    services.libreddit.port = 32001;

    services.nginx.virtualHosts."${libredditDomain}" = {
      forceSSL = true;
      useACMEHost = "nixalted.com";

      locations."/" = {
        proxyPass = "http://localhost:${libredditPort}";
        proxyWebsockets = true;
      };

      extraConfig = ''
        allow 100.0.0.0/8;
        deny  all;
      '';
    };
  };
}
