{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.libreddit;
  hostname = config.networking.hostName;
  libredditPort = toString config.services.libreddit.port;
  libredditDomain = "libreddit.${hostname}.me";
in {
  options.nixchad.libreddit = {
    enable = mkEnableOption "Libreddit Reddit proxying service";
  };

  config = mkIf cfg.enable {
    services.libreddit.enable = true;
    services.libreddit.port = 32001;

    # don't use SSL certs
    services.nginx.virtualHosts."${libredditDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.me/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.me/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${libredditPort}";
        proxyWebsockets = true;
      };
    };
    networking.extraHosts = ''
      127.0.0.1 ${libredditDomain}
    '';
  };
}
