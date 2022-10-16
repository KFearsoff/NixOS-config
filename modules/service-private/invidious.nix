{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.invidious;
  hostname = config.networking.hostName;
  invidiousPort = toString config.services.invidious.port;
  invidiousDomain = "invidious.${hostname}.me";
in {
  options.nixchad.invidious = {
    enable = mkEnableOption "Invidious Youtube proxying service";
  };

  config = mkIf cfg.enable {
    services.invidious.enable = true;
    services.invidious.port = 32000;
    services.invidious.domain = invidiousDomain;

    # don't use SSL certs
    services.nginx.virtualHosts."${invidiousDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.me/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.me/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${invidiousPort}";
      };
    };
    networking.extraHosts = ''
      127.0.0.1 ${invidiousDomain}
    '';
  };
}
