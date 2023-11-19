{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.nitter;
  nitterPort = config.services.nitter.server.port;
  nitterDomain = "nitter.nixalted.com";
in {
  options.nixchad.nitter = {
    enable = mkEnableOption "Nitter Twitter proxying service";
  };

  config = mkIf cfg.enable {
    services = {
      nitter = {
        enable = true;
        server.port = 32002;
        server.hostname = nitterDomain;
      };
      redis.vmOverCommit = true;
    };

    nixchad.nginx.vhosts."nitter" = {
      port = nitterPort;
    };
  };
}
