{
  pkgs,
  lib,
  config,
  ...
}: let
  autoresticCfg =
    pkgs.writeText "autorestic.yaml" (builtins.readFile ./autorestic.yaml);
in {
  systemd.services."autorestic-backup" = lib.mkMerge [
    {
      path = [pkgs.openssh pkgs.restic pkgs.coreutils];
      environment = {
        RESTIC_CACHE_DIR = "%C/restic";
      };
      preStart = ''
        ln -sf ${autoresticCfg} $STATE_DIRECTORY/autorestic.yaml
      '';
      script = "${pkgs.autorestic}/bin/autorestic -c $STATE_DIRECTORY/autorestic.yaml --ci cron";
      serviceConfig = {
        User = "root";
        Type = "oneshot";
        StateDirectory = "autorestic";
        CacheDirectory = "restic";
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
