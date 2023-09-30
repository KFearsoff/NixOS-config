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

  backup-builder = builtins.mapAttrs (_: recursiveUpdate template);
  template = {
    passwordFile = "/secrets/restic-backup-linus";
    repository = "sftp:kfears@sol.sphalerite.tech:/backup";
    user = username;
    extraOptions = [
      "sftp.command='ssh kfears@sol.sphalerite.tech -i /home/${username}/.ssh/id_ed25519 -o StrictHostKeyChecking=no -s sftp'"
    ];
    initialize = true;
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "5h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };

  backupLocations = {
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

  config = mkMerge [
    (mkIf cfg.enable {
      services.restic.backups = backup-builder backupLocations;
    })
    (mkIf (cfg.enable && config.networking.hostName != "cloudberry") {
      services.restic.backups = backup-builder {
        photos = {
          paths = [
            "/home/${username}/Pictures/Photos"
            "/home/${username}/Pictures/Photos-phone"
          ];
          extraBackupArgs = ["--verbose" "--host common" "--tag photos"];
        };
      };
    })
    (mkIf (cfg.enable && cfg.usb-backups) {
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
    })
    (mkIf config.services.postgresql.enable {
      services.restic.backups = backup-builder {
        postgres = {
          user = "root";
          paths = [
            "/tmp/postgres"
          ];
          extraBackupArgs = ["--verbose" "--tag postgres"];
          backupPrepareCommand = ''
            echo 'creating temporary directory'
            mkdir -p /tmp/postgres
            echo 'dumping PostgreSQL database'
            ${pkgs.shadow.su}/bin/su postgres -c ${config.services.postgresql.package}/bin/pg_dumpall > /tmp/postgres/pgdump.sql
          '';
          backupCleanupCommand = ''
            rm -rfv /tmp/postgres
          '';
        };
      };
    })
    (mkIf config.services.vaultwarden.enable {
      services.restic.backups = backup-builder {
        vaultwarden = {
          user = "root";
          paths = [
            "/tmp/vaultwarden"
          ];
          extraBackupArgs = ["--verbose" "--tag vaultwarden"];
          backupPrepareCommand = ''
            echo 'creating temporary directory'
            mkdir -p /tmp/vaultwarden
            echo 'copying Vaultwarden data'
            cp --reflink=auto -r /var/lib/bitwarden_rs /tmp/vaultwarden
          '';
          backupCleanupCommand = ''
            rm -rfv /tmp/vaultwarden
          '';
        };
      };
    })
  ];
}
