{
  config,
  lib,
  ...
}:
# taken from https://github.com/Misterio77/nix-config/blob/a6d0e8c039d9bdfb8e1d3c347ef793e6adfa0839/hosts/common/optional/ephemeral-btrfs.nix
with lib;
let
  cfg = config.nixchad.impermanence;
  wipeScript = ''
    mkdir /tmp -p
    MNTPOINT=$(mktemp -d)
    (
      mount -t btrfs -o subvol=/ /dev/disk/by-label/root "$MNTPOINT"
      trap 'umount "$MNTPOINT"' EXIT

      echo "Cleaning root subvolume"
      btrfs subvolume list -o "$MNTPOINT/root" | cut -f9 -d ' ' |
      while read -r subvolume; do
        btrfs subvolume delete "$MNTPOINT/$subvolume"
      done && btrfs subvolume delete "$MNTPOINT/root"

      echo "Restoring blank subvolume"
      btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
    )
  '';
  phase1Systemd = config.boot.initrd.systemd.enable;

  collectPersistedValues = builtins.foldl' processPersistedValues {
    hideMounts = true;
  } cfg.persisted.values;
  processPersistedValues = val: col: {
    files = (maybeFile val) ++ (maybeFile col);
    directories = (maybeDir val) ++ (maybeDir col);
  };
  maybe = attrname: lib.attrByPath [ attrname ] [ ];
  maybeFile = maybe "files";
  maybeDir = maybe "directories";
in
{
  options.nixchad.impermanence = {
    enable = mkEnableOption "impermanence";

    presets = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "presets at large";
          essential = mkEnableOption "essential presets";
          system = mkEnableOption "system-wide presets";
          services = mkEnableOption "presets for services";
        };
      };
    };

    persisted = {
      path = mkOption {
        type = types.str;
        default = "/persist";
      };

      values = mkOption {
        type = types.listOf (types.attrsOf types.anything);
      };
    };
  };

  config = mkIf cfg.enable {
    boot.tmp.cleanOnBoot = true;
    programs.fuse.userAllowOther = true;

    environment.persistence.${cfg.persisted.path} = mkIf cfg.presets.enable collectPersistedValues;

    nixchad.impermanence.persisted.values = [
      {
        directories = mkIf cfg.presets.essential [
          "/var/log"
          "/var/lib/systemd"
          "/var/lib/nixos"
        ];

        files = mkIf cfg.presets.essential [
          "/etc/machine-id"
        ];
      }
    ];

    boot.initrd = {
      supportedFilesystems = [ "btrfs" ];
      postDeviceCommands = mkIf (!phase1Systemd) (mkBefore wipeScript);
      systemd.services.restore-root = mkIf phase1Systemd {
        description = "Rollback btrfs rootfs";
        wantedBy = [ "initrd.target" ];
        requires = [ "dev-disk-by\\x2dlabel-root.device" ];
        after = [
          "dev-disk-by\\x2dlabel-root.device"
          "systemd-cryptsetup@crypted.service" # has to be "unlockedpartname.service"
        ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = wipeScript;
      };
    };
  };
}
