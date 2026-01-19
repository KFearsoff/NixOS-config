{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  nixchad.resticModule = {
    enable = true;

    sources = {
      secrets = {
        paths = [
          "/secrets"
        ];
      };
      stuff = {
        paths = [
          "/home/${username}/Sync"
        ];
      };
      photos = {
        paths = [
          "/home/${username}/Pictures/Photos"
          "/home/${username}/Pictures/Photos-phone"
        ];
      };
      postgres = {
        paths = [
          "/tmp/postgres"
        ];
        unitOptions = {
          preStart = ''
            echo 'creating temporary directory'
            mkdir -p /tmp/postgres
            echo 'dumping PostgreSQL database'
            ${pkgs.shadow.su}/bin/su postgres -c ${config.services.postgresql.package}/bin/pg_dumpall > /tmp/postgres/pgdump.sql
          '';
          postStop = ''
            rm -rfv /tmp/postgres
          '';
        };
      };
      vaultwarden = {
        paths = [
          "/tmp/vaultwarden"
        ];
        unitOptions = {
          preStart = ''
            echo 'creating temporary directory'
            mkdir -p /tmp/vaultwarden
            echo 'copying Vaultwarden data'
            cp --reflink=auto -r /var/lib/bitwarden_rs /tmp/vaultwarden
          '';
          postStop = ''
            rm -rfv /tmp/vaultwarden
          '';
        };
      };
      paperless = {
        paths = [
          config.services.paperless.dataDir
        ];
      };
    };

    destinations = {
      linus = {
        settings = {
          RESTIC_REPOSITORY = "sftp:kfears@sol.sphalerite.tech:/backup";
          RESTIC_PASSWORD_FILE = "/secrets/restic-backup-linus";
        };
        extraOptions = [
          "sftp.command='ssh kfears@sol.sphalerite.tech -i /home/${username}/.ssh/id_ed25519 -o StrictHostKeyChecking=no -s sftp'"
        ];
      };
    };

    mappings = {
      linus = {
        sources = [
          "secrets"
          "stuff"
          "photos"
          "postgres"
          "vaultwarden"
          "paperless"
        ];
        destinations = [ "linus" ];
      };
    };
  };
}
