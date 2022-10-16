{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.nitter;
  hostname = config.networking.hostName;
  nitterPort = toString config.services.nitter.server.port;
  nitterDomain = "nitter.${hostname}.me";
in {
  options.nixchad.nitter = {
    enable = mkEnableOption "Nitter Twitter proxying service";
  };

  config = mkIf cfg.enable {
    services.nitter.enable = true;
    services.nitter.server.port = 32002;
    services.nitter.server.hostname = nitterDomain;

    # don't use SSL certs
    services.nginx.virtualHosts."${nitterDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.me/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.me/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${nitterPort}";
      };
    };
  };
}
