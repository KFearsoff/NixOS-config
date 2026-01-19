{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  # Type for a valid systemd unit option. Needed for correctly passing "timerConfig" to "systemd.timers"
  inherit (utils.systemdUtils.unitOptions) unitOption;
in
{
  options.nixchad.resticModule = {
    enable = lib.mkEnableOption "restic" // {
      default = true;
    };

    sources = lib.mkOption {
      description = ''
        Sources from which backups will be created.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              unitOptions = lib.mkOption {
                description = "Additional systemd unit options";
                type = unitOption;
                default = { };
              };

              paths = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = ''
                  Which paths to backup, in addition to ones specified via
                  `dynamicFilesFrom`.  If null or an empty array and
                  `dynamicFilesFrom` is also null, no backup command will be run.
                    This can be used to create a prune-only job.
                '';
                example = [
                  "/var/lib/postgresql"
                  "/home/user/backup"
                ];
              };

              command = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = ''
                  Command to pass to --stdin-from-command. If null or an empty array, and `paths`/`dynamicFilesFrom`
                  are also null, no backup command will be run.
                '';
                example = [
                  "sudo"
                  "-u"
                  "postgres"
                  "pg_dumpall"
                ];
              };

              exclude = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = ''
                  Patterns to exclude when backing up. See
                  https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files for
                  details on syntax.
                '';
                example = [
                  "/var/cache"
                  "/home/*/.cache"
                  ".git"
                ];
              };

              dynamicFilesFrom = lib.mkOption {
                type = with lib.types; nullOr str;
                default = null;
                description = ''
                  A script that produces a list of files to back up.  The
                  results of this command are given to the '--files-from'
                  option. The result is merged with paths specified via `paths`.
                '';
                example = "find /home/matt/git -type d -name .git";
              };
            };
          }
        )
      );
    };

    destinations = lib.mkOption {
      description = ''
        Destinations where backups will be stored.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              init = lib.mkOption {
                description = "Whether to init the destination repository prior to doing any backups";
                type = lib.types.bool;
                default = true;
              };

              unitOptions = lib.mkOption {
                description = "Additional systemd unit options";
                type = unitOption;
                default = { };
              };

              extraOptions = lib.mkOption {
                description = "Additional options added to restic invokation via '-o' flag";
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };

              settings = lib.mkOption {
                description = ''
                  Restic settings. They are provided as environment variables. They should be provided in upper snake
                  case (e.g. {env}`RESTIC_PASSWORD_FILE`). See
                  <https://restic.readthedocs.io/en/stable/040_backup.html#environment-variables> for supported options.

                  This option can also take rclone settings, also as environment variables. They should be provided in
                  upper snake case (e.g. {env}`RCLONE_SKIP_LINKS`). See <https://rclone.org/docs/#options> for supported
                  options. Restic will automatically supply the remote type and name for you. To provide secrets to the
                  backend, it's recommended to create rclone config file yourself, and use {env}`RCLONE_CONFIG` option
                  to point to it. It is also recommended to use a separate config file if you care about
                  case-sensitivity for your remote name.
                '';
                type = lib.types.submodule {
                  freeformType =
                    with lib.types;
                    attrsOf (oneOf [
                      str
                      (listOf str)
                    ]);

                  options = {
                    RESTIC_REPOSITORY = lib.mkOption {
                      type = with lib.types; nullOr str;
                      default = null;
                      description = ''
                        repository to backup to.
                      '';
                      example = "sftp:backup@192.168.1.100:/backups/my-backup";
                    };
                    RESTIC_REPOSITORY_FILE = lib.mkOption {
                      type = with lib.types; nullOr path;
                      default = null;
                      description = ''
                        Path to the file containing the repository location to backup to.
                      '';
                    };
                    RESTIC_PASSWORD_FILE = lib.mkOption {
                      type = lib.types.str;
                      default = "";
                      description = ''
                        Read the repository password from a file.
                      '';
                      example = "/etc/nixos/restic-password";
                    };

                    RCLONE_CONFIG = lib.mkOption {
                      type =
                        with lib.types;
                        nullOr (oneOf [
                          str
                          path
                        ]);
                      default = null;
                      description = ''
                        Location of the rclone configuration file.
                      '';
                    };
                  };
                };
                example = lib.literalExpression ''
                  RESTIC_REPOSITORY = "s3:s3.us-east-1.amazonaws.com/bucket_name/restic";
                  RESTIC_PASSWORD_FILE = "/secrets/password-file";
                  AWS_ACCESS_KEY_ID = "XXXX";
                  AWS_SECRET_ACCESS_KEY = "YYYY";
                  RCLONE_BWLIMIT = "10M";
                  RCLONE_HARD_DELETE = "true";
                  # RCLONE_S3_PROVIDER = "AWS";
                  # RCLONE_CONFIG_MYS3_ACCESS_KEY_ID = "XXXX";
                  # RCLONE_CONFIG = "/my/config/file";
                '';
              };
            };
          }
        )
      );
    };

    mappings = lib.mkOption {
      description = ''
        Mappings between sources and destinations.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              sources = lib.mkOption {
                description = "Backup sources";
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              destinations = lib.mkOption {
                description = "Backup destinations";
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        )
      );
    };
  };

  config =
    let
      extraOptions =
        name:
        lib.concatMapStrings (arg: " -o ${arg}") (
          lib.getAttrFromPath [ name "extraOptions" ] config.nixchad.resticModule.destinations
        );
      inhibitCmd =
        name:
        lib.concatStringsSep " " [
          "${pkgs.systemd}/bin/systemd-inhibit"
          "--mode='block'"
          "--who='restic'"
          "--what='idle:sleep:shutdown:handle-lid-switch'"
          "--why=${lib.escapeShellArg "Scheduled backup ${name}"} "
        ];
      resticCmd = name: "${inhibitCmd name}${lib.getExe pkgs.restic}${extraOptions name}";

      destinationTemplater = name: destination: {
        environment = destination.settings;
        path = [ config.programs.ssh.package ];
        restartIfChanged = false;
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${resticCmd name} cat config > /dev/null || ${resticCmd name} init";
          User = "root";
          Group = "root";
          RuntimeDirectory = "restic-destination-${name}";
          CacheDirectory = "restic-destination-${name}";
          CacheDirectoryMode = "0700";
          PrivateTmp = true;
        };
      };

      # mapping is { sources = "foo"; destinations = "bar"; }
      backupTemplater = mapping: {
        environment = lib.getAttrFromPath [
          mapping.destinations
          "settings"
        ] config.nixchad.resticModule.destinations;
        path = [ config.programs.ssh.package ];
        restartIfChanged = false;
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${resticCmd} backup";
          User = "root";
          Group = "root";
          RuntimeDirectory = "restic-destination-${mapping.destinations}";
          CacheDirectory = "restic-destination-${mapping.destinations}";
          CacheDirectoryMode = "0700";
          PrivateTmp = true;
        };
      };

      destinationServices =
        config.nixchad.resticModule.destinations
        |> lib.mapAttrs' (
          name: value: {
            name = "restic-destination-${name}";
            value = destinationTemplater name value;
          }
        );

      transformMapping =
        mapping:
        mapping
        |> lib.cartesianProduct
        |> lib.map (attrset: {
          name = "restic-backup-${attrset.sources}-to-${attrset.destinations}";
          value = backupTemplater attrset;
        })
        |> lib.listToAttrs;

      backupServices =
        config.nixchad.resticModule.mappings
        |> lib.mapAttrs (name: mapping: transformMapping mapping)
        |> lib.foldlAttrs (
          acc: _name: value:
          acc // value
        ) { };
    in
    {
      systemd.services = destinationServices // backupServices;
    };
}
