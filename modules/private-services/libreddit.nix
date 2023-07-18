{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.libreddit;
  libredditPort = config.services.libreddit.port;
in {
  options.nixchad.libreddit = {
    enable = mkEnableOption "Libreddit Reddit proxying service";
  };

  config = mkIf cfg.enable {
    services.libreddit.enable = true;
    services.libreddit.port = 32001;

    nixchad.nginx.vhosts."libreddit" = {
      port = libredditPort;
    };
  };
}
