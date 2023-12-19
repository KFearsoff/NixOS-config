{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.freshrss;
  baseDomain = "nixalted.com";
  domain = "freshrss.${baseDomain}";
in {
  options.nixchad.freshrss = {
    enable = mkEnableOption "Freshrss";
  };

  config = mkIf cfg.enable {
    services = {
      freshrss = {
        enable = true;
        baseUrl = "https://${domain}";
        # authType = "none";
        passwordFile = ./freshrss-pass;
        virtualHost = domain;
        database = {
          type = "pgsql";
          host = "/run/postgresql"; # socket auth
        };
      };

      postgresql = {
        ensureDatabases = ["freshrss"];
        ensureUsers = [
          {
            name = "freshrss";
            ensureDBOwnership = true;
          }
        ];
      };

      nginx.virtualHosts."${domain}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        quic = true;
        kTLS = true;
      };
    };

    security.acme.certs."${baseDomain}".extraDomainNames = [domain];

    # make sure we don't crash because postgres isn't ready
    systemd.services.phpfpm-freshrss.after = ["postgresql.service"];

    nixchad.impermanence.persisted.values = [
      {
        directories =
          lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
          [config.services.freshrss.dataDir];
      }
    ];
  };
}
