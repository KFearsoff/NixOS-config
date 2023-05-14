{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.vaultwarden;
  vaultwardenPort = 32003;
  domain = "vaultwarden.nixalted.com";
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

        domain = "https://${domain}";
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
      useACMEHost = "nixalted.com";

      locations."/" = {
        proxyPass = "http://localhost:${toString vaultwardenPort}";
        proxyWebsockets = true;
      };
      locations."/notifications/hub" = {
        proxyPass = "http://localhost:3012";
        proxyWebsockets = true;
      };
      locations."/notifications/hub/negotiate" = {
        proxyPass = "http://localhost:${toString vaultwardenPort}";
        proxyWebsockets = true;
      };

      extraConfig = ''
        allow 100.100.100.100/8;
        deny  all;
      '';
    };

    # make sure we don't crash because postgres isn't ready
    systemd.services.vaultwarden.after = ["postgresql.service"];
  };
}
