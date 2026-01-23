{
  config,
  lib,
  pkgs,
  username,
  ...
}:
let
  photos = config.networking.hostName != "cloudberry";
  postgres = config.services.postgresql.enable;
  vaultwarden = config.services.vaultwarden.enable;
  paperless = config.services.paperless.enable;
in
{
  nixchad.resticModule = (
    lib.mkIf config.nixchad.resticModule.enable {
      sources = lib.mkMerge [
        {
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
        }
        (lib.mkIf photos {
          photos = {
            paths = [
              "/home/${username}/Pictures/Photos"
              "/home/${username}/Pictures/Photos-phone"
            ];
          };
        })
        (lib.mkIf postgres {
          postgres = {
            paths = [
              "/tmp/postgres"
            ];
            backupPre = ''
              echo 'creating temporary directory'
              mkdir -p /tmp/postgres
              echo 'dumping PostgreSQL database'
              ${pkgs.shadow.su}/bin/su postgres -c ${config.services.postgresql.package}/bin/pg_dumpall > /tmp/postgres/pgdump.sql
            '';
            backupPost = ''
              rm -rfv /tmp/postgres
            '';
          };
        })
        (lib.mkIf vaultwarden {
          vaultwarden = {
            paths = [
              "/tmp/vaultwarden"
            ];
            backupPre = ''
              echo 'creating temporary directory'
              mkdir -p /tmp/vaultwarden
              echo 'copying Vaultwarden data'
              cp --reflink=auto -r /var/lib/bitwarden_rs /tmp/vaultwarden
            '';
            backupPost = ''
              rm -rfv /tmp/vaultwarden
            '';
          };
        })
        (lib.mkIf paperless {
          paperless = {
            paths = [
              config.services.paperless.dataDir
            ];
          };
        })
      ];

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
          ]
          ++ (lib.optional photos "photos")
          ++ (lib.optional postgres "postgres")
          ++ (lib.optional vaultwarden "vaultwarden")
          ++ (lib.optional paperless "paperless");
          destinations = [ "linus" ];
        };
      };
    }
  );
}
