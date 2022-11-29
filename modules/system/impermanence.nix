{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.impermanence;
in {
  options.nixchad.impermanence = {
    enable = mkEnableOption "impermanence";
  };

  config = mkIf cfg.enable {
    boot.cleanTmpDir = true;
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

    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/disk/by-label/root /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
        mv /btrfs_tmp/root "/btrfs_tmp/old_root_$(date "+%Y-%m-%-d_%H:%M:%S")"
      fi
      btrfs subvolume create /btrfs_tmp/root
      sync
      umount /btrfs_tmp
    '';

    services = {
      openssh = {
        enable = true;
        passwordAuthentication = false;
        permitRootLogin = "no";
        kbdInteractiveAuthentication = false;
      };
    };
  };
}
