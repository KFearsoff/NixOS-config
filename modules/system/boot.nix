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

    boot.loader.grub = mkIf (cfg.bootloader == "grub") {
      enable = true;
      version = 2;
      efiSupport = true;
      device = "nodev";
      efiInstallAsRemovable = true;
    };

    boot.loader.grub = mkIf (cfg.bootloader == "grub-noefi") {
      enable = true;
      version = 2;
      device = "sda";
    };
  };
}
