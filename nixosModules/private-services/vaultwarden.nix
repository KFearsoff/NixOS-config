{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.vaultwarden;
  vaultwardenPort = 32003;
  domain = "vaultwarden.nixalted.com";
in
{
  options.nixchad.vaultwarden = {
    enable = mkEnableOption "Vaultwarden";
  };

  config = mkIf cfg.enable {
    services = {
      vaultwarden = {
        enable = true;
        dbBackend = "postgresql";
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = vaultwardenPort;
          DOMAIN = "https://${domain}";

          DATABASE_URL = "postgresql://vaultwarden@/vaultwarden";

          SIGNUPS_ALLOWED = false;
          SHOW_PASSWORD_HINT = false;
        };
      };

      postgresql = {
        ensureDatabases = [ "vaultwarden" ];
        ensureUsers = [
          {
            name = "vaultwarden";
            ensureDBOwnership = true;
          }
        ];
      };

      caddy.virtualHosts."vaultwarden.nixalted.com" = {
        logFormat = ''
          output file ${config.services.caddy.logDir}/access-vaultwarden.nixalted.com.log {
            mode 0640
          }
        '';
        extraConfig = ''
          reverse_proxy :${toString vaultwardenPort}
        '';
      };
    };

    # make sure we don't crash because postgres isn't ready
    systemd.services.vaultwarden.after = [ "postgresql.service" ];
  };
}
