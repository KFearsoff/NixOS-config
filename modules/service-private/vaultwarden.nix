{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.vaultwarden;
  hostname = config.networking.hostName;
  vaultwardenPort = "32003";
  vaultwardenDomain = "vaultwarden.${hostname}.me";
in {
  options.nixchad.vaultwarden = {
    enable = mkEnableOption "Vaultwarden";
  };

  config = mkIf cfg.enable {
    services.vaultwarden.enable = true;
    services.vaultwarden.config = {
      DOMAIN = "https://${vaultwardenDomain}";
      ROCKET_PORT = vaultwardenPort;
    };

    # don't use SSL certs
    services.nginx.virtualHosts."${vaultwardenDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.me/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.me/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${vaultwardenPort}";
        proxyWebsockets = true;
      };
      locations."/notifications/hub" = {
        proxyPass = "http://localhost:3012";
        proxyWebsockets = true;
      };
      locations."/notifications/hub/negotiate" = {
        proxyPass = "http://localhost:${vaultwardenPort}";
        proxyWebsockets = true;
      };
    };
    networking.extraHosts = ''
      127.0.0.1 ${vaultwardenDomain}
    '';
  };
}
