{
  config,
  lib,
  pkgs,
  username,
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

    services.restic.backups = let
      usb-template = {
        passwordFile = "/secrets/usb-flash-drive-backup";
        user = username;
        repository = "/run/media/${username}/Ventoy/restic-backups";
      };
    in
      builtins.mapAttrs (_: value: usb-template // value) {
        init-usb-repo = {
          initialize = true;
          backupPrepareCommand = "${pkgs.coreutils}/bin/sleep 1";
        };
        photos-usb = {
          paths = [
            "/home/${username}/Pictures/Photos"
            "/home/${username}/Pictures/Photos-phone"
          ];
          extraBackupArgs = ["--verbose" "--host common" "--tag photos"];
        };
        secrets-usb = {
          paths = [
            "/secrets"
          ];
          extraBackupArgs = ["--verbose" "--tag secrets"];
        };
        stuff-usb = {
          paths = [
            "/home/${username}/Sync"
          ];
          extraBackupArgs = ["--verbose" "--host common" "--tag stuff"];
        };
      };

    systemd = let
      device = "dev-disk-by\\x2duuid-8277\\x2dDD24.device";
    in {
      services.restic-backups-photos-usb = {
        after = [device "restic-backups-init-usb-repo.service"];
        wantedBy = [device];
      };
      timers.restic-backups-photos-usb.enable = false;
      services.restic-backups-secrets-usb = {
        after = [device "restic-backups-init-usb-repo.service"];
        wantedBy = [device];
      };
      timers.restic-backups-secrets-usb.enable = false;
      services.restic-backups-stuff-usb = {
        after = [device "restic-backups-init-usb-repo.service"];
        wantedBy = [device];
      };
      timers.restic-backups-stuff-usb.enable = false;
      services.restic-backups-init-usb-repo = {
        after = [device];
        wantedBy = [device];
        serviceConfig.ExecStart = ["${pkgs.coreutils}/bin/echo \"restic repository initialized\""];
      };
      timers.restic-backups-init-usb-repo.enable = false;
    };
  };
}
