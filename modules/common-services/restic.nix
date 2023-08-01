{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.restic;
  backup-builder = builtins.mapAttrs (_: recursiveUpdate template);
  template = {
    passwordFile = "/secrets/usb-flash-drive-backup";
    user = username;
    repository = "/run/media/${username}/Ventoy/restic-backups";
  };

  systemd-collector = foldl' recursiveUpdate {} systemd-builder;
  systemd-builder = builtins.map systemd-fn (builtins.attrNames backupLocations);
  systemd-fn = name: {
    services."restic-backups-${name}" = {
      after = ["restic-backups-init-repo.service"];
      wantedBy = ["restic-backups-init-repo.service"];
    };
    timers."restic-backups-${name}".enable = false;
  };

  backupLocations = {
    photos = {
      paths = [
        "/home/${username}/Pictures/Photos"
        "/home/${username}/Pictures/Photos-phone"
      ];
      extraBackupArgs = ["--verbose" "--host common" "--tag photos"];
    };
    secrets = {
      paths = [
        "/secrets"
      ];
      extraBackupArgs = ["--verbose" "--tag secrets"];
    };
    stuff = {
      paths = [
        "/home/${username}/Sync"
      ];
      extraBackupArgs = ["--verbose" "--host common" "--tag stuff"];
    };
  };
in {
  options.nixchad.restic = {
    enable = mkEnableOption "Restic backups";
    usb-backups = mkEnableOption "backups to USB drive";
  };

  config = mkIf (cfg.enable && cfg.usb-backups) {
    hm.home.packages = [pkgs.restic];

    services.restic.backups = backup-builder ({
        init-repo = {
          initialize = true;
          backupPrepareCommand = "${pkgs.coreutils}/bin/sleep 1";
        };
      }
      // backupLocations);

    systemd = let
      device = "dev-disk-by\\x2duuid-8277\\x2dDD24.device";
    in
      optionalAttrs cfg.usb-backups (recursiveUpdate
        {
          services.restic-backups-init-repo = {
            after = [device];
            wantedBy = [device];
            serviceConfig.ExecStart = ["${pkgs.coreutils}/bin/echo \"restic repository initialized\""];
          };
          timers.restic-backups-init-repo.enable = false;
        }
        systemd-collector);
  };
}
