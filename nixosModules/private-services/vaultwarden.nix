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
    services.vaultwarden = {
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

    services.postgresql = {
      ensureDatabases = [ "vaultwarden" ];
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
    };

    nixchad.nginx.vhosts."vaultwarden" = {
      websockets = true;
      port = vaultwardenPort;
    };

    # make sure we don't crash because postgres isn't ready
    systemd.services.vaultwarden.after = [ "postgresql.service" ];
  };
}
