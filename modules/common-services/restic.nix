{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.restic;
in {
  options.nixchad.restic = {
    enable = mkEnableOption "Restic backups";
  };

  config = mkIf cfg.enable {
    hm.home.packages = [pkgs.restic];

    services.restic.backups = {
      usb-flash-drive = {
        initialize = true;
        passwordFile = "/secrets/usb-flash-drive-backup";
        paths = [
          "/home/nixchad/Pictures/Photos"
          "/home/nixchad/Pictures/Photos-phone"
          "/home/nixchad/Sync"
        ];
        user = "nixchad";
        repository = "/run/media/nixchad/Ventoy/restic-backups";
        backupPrepareCommand = "${pkgs.coreutils}/bin/sleep 5";
        extraBackupArgs = ["--host=common" "--verbose"];
      };
    };

    systemd.services.restic-backups-usb-flash-drive = {
      after = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device"];
      wantedBy = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device"];
    };
    systemd.timers.restic-backups-usb-flash-drive = mkForce {};
  };
}
