{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.restic;
  device = "dev-disk-by\\x2duuid-8277\\x2dDD24.device";
in {
  options.nixchad.restic = {
    enable = mkEnableOption "Restic backups";
    usb-backups = mkEnableOption "backups to USB drive";
  };

  config = mkIf (cfg.enable && cfg.usb-backups) {
    hm.home.packages = [pkgs.restic];

    systemd.services."usb-restic-backup" = {
      path = [pkgs.openssh];
      environment = {
        RESTIC_CACHE_DIR = "%C/restic-backups";
        RESTIC_FROM_PASSWORD_FILE = /secrets/restic-backup-linus;
        RESTIC_PASSWORD_FILE = /secrets/usb-flash-drive-backup;
      };
      preStart = ''
        ${pkgs.coreutils}/bin/sleep 5
        ${pkgs.restic}/bin/restic snapshots || ${pkgs.restic}/bin/restic init
      '';
      script = "${pkgs.restic}/bin/restic copy -r /run/media/${username}/Ventoy/restic-backups --from-repo 4.sosiego.sphalerite.org:/backup";
      after = [device];
      wantedBy = [device];
      serviceConfig = {
        User = "nixchad";
        Type = "oneshot";
        RuntimeDirectory = "restic-backups";
        CacheDirectory = "restic-backups";
        CacheDirectoryMode = "0700";
        PrivateTmp = true;
      };
    };
  };
}
