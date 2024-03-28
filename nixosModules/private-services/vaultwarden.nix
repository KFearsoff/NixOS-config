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

        databaseUrl = "postgresql://vaultwarden@/vaultwarden";

        domain = "https://${domain}";
      };
    };

    services.postgresql = {
      ensureDatabases = ["vaultwarden"];
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
    systemd.services.vaultwarden.after = ["postgresql.service"];
  };
}
