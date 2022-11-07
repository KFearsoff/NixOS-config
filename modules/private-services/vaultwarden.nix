{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.vaultwarden;
  hostname = config.networking.hostName;
  vaultwardenPort = 32003;
  domain = "${hostname}.tail34ad.ts.net";
in {
  options.nixchad.vaultwarden = {
    enable = mkEnableOption "Vaultwarden";
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        rocketAddress = "0.0.0.0";
        rocketPort = vaultwardenPort;

        websocketEnabled = true;
        websocketAddress = "0.0.0.0";
        websocketPort = 3012;

        databaseUrl = "postgresql://vaultwarden@/vaultwarden";

        domain = "https://${domain}/vault";
      };
    };

    services.postgresql = {
      ensureDatabases = ["vaultwarden"];
      ensureUsers = [
        {
          name = "vaultwarden";
          ensurePermissions."DATABASE vaultwarden" = "ALL PRIVILEGES";
        }
      ];
    };

    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/${domain}.crt";
      sslCertificateKey = "/var/lib/self-signed/${domain}.key";

      locations."/vault" = {
        proxyPass = "http://localhost:${toString vaultwardenPort}";
        proxyWebsockets = true;
      };
      locations."/vault/notifications/hub" = {
        proxyPass = "http://localhost:3012";
        proxyWebsockets = true;
      };
      locations."/vault/notifications/hub/negotiate" = {
        proxyPass = "http://localhost:${toString vaultwardenPort}";
        proxyWebsockets = true;
      };
    };

    # make sure we don't crash because postgres isn't ready
    systemd.services.vaultwarden.after = ["postgresql.service"];
  };
}
