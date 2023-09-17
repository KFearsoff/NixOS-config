{
  pkgs,
  lib,
  config,
  ...
}: let
  autoresticCfg =
    pkgs.writeText "autorestic.yaml" (builtins.readFile ./autorestic.yaml);
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/autorestic 0755 nixchad users 10d -"
    "L /var/lib/autorestic/autorestic.yaml - - - - ${autoresticCfg}"
  ];

  systemd.services."autorestic-backup" = lib.mkMerge [
    {
      path = [pkgs.openssh pkgs.restic pkgs.coreutils];
      environment = {
        RESTIC_CACHE_DIR = "%C/restic-backups";
      };
      script = "${pkgs.autorestic}/bin/autorestic -c /var/lib/autorestic/autorestic.yaml --ci cron";
      serviceConfig = {
        User = "root";
        Type = "oneshot";
        RuntimeDirectory = "restic-backups";
        CacheDirectory = "restic-backups";
        CacheDirectoryMode = "0700";
        PrivateTmp = true;
      };
    }
    (lib.mkIf config.services.postgresql.enable {
      preStart = ''
        echo 'dumping PostgreSQL database'
        ${pkgs.shadow.su}/bin/su postgres -c ${config.services.postgresql.package}/bin/pg_dumpall > /secrets/pgdump.sql
      '';

      postStart = ''
        rm -v /secrets/pgdump.sql
      '';
    })
    (lib.mkIf config.services.vaultwarden.enable {
      preStart = ''
        echo 'copying Vaultwarden data'
        cp --reflink=auto -r /var/lib/bitwarden_rs /secrets/vaultwarden
      '';

      postStart = ''
        rm -rfv /secrets/vaultwarden
      '';
    })
  ];

  systemd.timers."autorestic-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
