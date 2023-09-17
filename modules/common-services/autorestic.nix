{pkgs, ...}: let
  autoresticCfg =
    pkgs.writeText "autorestic.yaml" (builtins.readFile ./autorestic.yaml);
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/autorestic 0755 nixchad users 10d -"
    "L /var/lib/autorestic/autorestic.yaml - - - - ${autoresticCfg}"
  ];

  systemd.services."autorestic-backup" = {
    path = [pkgs.openssh pkgs.restic pkgs.coreutils];
    environment = {
      RESTIC_CACHE_DIR = "%C/restic-backups";
    };
    serviceConfig = {
      ExecStart = "${pkgs.autorestic}/bin/autorestic -c /var/lib/autorestic/autorestic.yaml --ci cron";
      User = "nixchad";
      Type = "oneshot";
      RuntimeDirectory = "restic-backups";
      CacheDirectory = "restic-backups";
      CacheDirectoryMode = "0700";
      PrivateTmp = true;
    };
  };

  systemd.timers."autorestic-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
