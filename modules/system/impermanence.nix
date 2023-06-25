{
  config,
  lib,
  ...
}:
# taken from https://github.com/Misterio77/nix-config/blob/a6d0e8c039d9bdfb8e1d3c347ef793e6adfa0839/hosts/common/optional/ephemeral-btrfs.nix
with lib; let
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
in {
  options.nixchad.impermanence = {
    enable = mkEnableOption "impermanence";
  };

  config = mkIf cfg.enable {
    boot.tmp.cleanOnBoot = true;
    programs.fuse.userAllowOther = true;

    security.sudo.extraConfig = ''
      Defaults lecture = never
      Defaults insults
    '';
    environment.persistence."/persist" = {
      hideMounts = true;

      presets = {
        essential.enable = true;
        system.enable = true;
        services.enable = true;
      };

      directories = [
        "/var/log"
        "/var/lib/systemd"
      ];
    };

    boot.initrd = {
      supportedFilesystems = ["btrfs"];
      postDeviceCommands = mkIf (!phase1Systemd) (mkBefore wipeScript);
      systemd.services.restore-root = mkIf phase1Systemd {
        description = "Rollback btrfs rootfs";
        wantedBy = ["initrd.target"];
        requires = ["dev-disk-by\\x2dlabel-root.device"];
        after = [
          "dev-disk-by\\x2dlabel-root.device"
          #"systemd-cryptsetup@root.service" # TODO: check this!
        ];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = wipeScript;
      };
    };

    services = {
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          KbdInteractiveAuthentication = false;
        };
      };
    };
  };
}
