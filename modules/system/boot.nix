{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.boot;
in {
  options.nixchad.boot = {
    enable = mkEnableOption "boot";

    bootloader = mkOption {
      type = types.enum ["grub" "grub-noefi" "systemd-boot"];
      default = "systemd-boot";
    };
  };

  config = mkIf cfg.enable {
    boot = {
      kernelParams = ["quiet" "udev.log_priority=3" "vt.global_cursor_default=0"];
      consoleLogLevel = 0;
      initrd.verbose = false;
    };

    boot.loader.systemd-boot = mkIf (cfg.bootloader == "systemd-boot") {
      enable = true;
      consoleMode = "max";
      editor = false;
    };

    boot.loader.grub = mkIf (cfg.bootloader == "grub" || cfg.bootloader == "grub-noefi") {
      enable = true;
      version = 2;
      efiSupport = cfg.bootloader == "grub";
      device =
        if cfg.bootloader == "grub"
        then "nodev"
        else "/dev/sda";
      efiInstallAsRemovable = cfg.bootloader == "grub";
    };
  };
}
