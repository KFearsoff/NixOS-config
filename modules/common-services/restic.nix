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
      init-usb-repo = {
        initialize = true;
        passwordFile = "/secrets/usb-flash-drive-backup";
        user = "nixchad";
        repository = "/run/media/nixchad/Ventoy/restic-backups";
        backupPrepareCommand = "${pkgs.coreutils}/bin/sleep 5";
      };
      usb-flash-drive = {
        passwordFile = "/secrets/usb-flash-drive-backup";
        paths = [
          "/home/nixchad/Pictures/Photos"
          "/home/nixchad/Pictures/Photos-phone"
        ];
        user = "nixchad";
        repository = "/run/media/nixchad/Ventoy/restic-backups";
        backupPrepareCommand = "${pkgs.coreutils}/bin/sleep 5";
        extraBackupArgs = ["--verbose" "--host common" "--tag photos"];
      };
      secrets-usb = {
        passwordFile = "/secrets/usb-flash-drive-backup";
        paths = [
          "/secrets"
        ];
        user = "nixchad";
        repository = "/run/media/nixchad/Ventoy/restic-backups";
        backupPrepareCommand = "${pkgs.coreutils}/bin/sleep 5";
        extraBackupArgs = ["--verbose" "--tag secrets"];
      };
      stuff-usb = {
        passwordFile = "/secrets/usb-flash-drive-backup";
        paths = [
          "/home/nixchad/Sync"
        ];
        user = "nixchad";
        repository = "/run/media/nixchad/Ventoy/restic-backups";
        backupPrepareCommand = "${pkgs.coreutils}/bin/sleep 5";
        extraBackupArgs = ["--verbose" "--host common" "--tag stuff"];
      };
    };

    systemd.services.restic-backups-usb-flash-drive = {
      after = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device" "restic-backups-init-usb-repo.service"];
      wantedBy = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device"];
    };
    systemd.timers.restic-backups-usb-flash-drive.enable = false;
    systemd.services.restic-backups-secrets-usb = {
      after = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device" "restic-backups-init-usb-repo.service"];
      wantedBy = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device"];
    };
    systemd.timers.restic-backups-secrets-usb.enable = false;
    systemd.services.restic-backups-stuff-usb = {
      after = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device" "restic-backups-init-usb-repo.service"];
      wantedBy = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device"];
    };
    systemd.timers.restic-backups-stuff-usb.enable = false;
    systemd.services.restic-backups-init-usb-repo = {
      after = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device"];
      wantedBy = ["dev-disk-by\\x2duuid-8277\\x2dDD24.device"];
      serviceConfig.ExecStart = ["${pkgs.coreutils}/bin/echo \"restic repository initialized\""];
    };
    systemd.timers.restic-backups-init-usb-repo.enable = false;
  };
}
