{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.libreddit;
  hostname = config.networking.hostName;
  libredditPort = toString config.services.libreddit.port;
  libredditDomain = "libreddit.${hostname}.box";
in {
  options.nixchad.libreddit = {
    enable = mkEnableOption "Libreddit Reddit proxying service";
  };

  config = mkIf cfg.enable {
    services.libreddit.enable = true;
    services.libreddit.port = 32001;

    # It doesn't seem like Libreddit allows subpaths. Wait for this:
    # https://github.com/tailscale/tailscale/issues/1235#issuecomment-927002943
    services.nginx.virtualHosts."${libredditDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.box/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.box/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${libredditPort}";
        proxyWebsockets = true;
      };
    };
  };
}
