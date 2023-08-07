{
  pkgs,
  lib,
  ...
}: let
  autoresticCfg =
    pkgs.writeText "autorestic.yaml" (builtins.readFile ./autorestic.yaml);
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/autorestic 0755 nixchad users 10d -"
  ];

  systemd.services."autorestic-backup" = {
    path = [pkgs.openssh pkgs.restic];
    environment = {
      RESTIC_CACHE_DIR = "%C/restic-backups";
    };
    preStart = ''
      ${lib.getBin pkgs.envsubst}/bin/envsubst -o "/tmp/autorestic-substituted.yaml" -i "${autoresticCfg}"
    '';
    serviceConfig = {
      ExecStart = "${pkgs.autorestic}/bin/autoresticCfg -c /tmp/autorestic-substituted.yaml --ci cron";
      EnvironmentFile = /secrets/restic-backup-linus;
      User = "nixchad";
      Type = "oneshot";
      RuntimeDirectory = "restic-backups";
      CacheDirectory = "restic-backups";
      CacheDirectoryMode = "0700";
      PrivateTmp = true;
    };
  };
}
