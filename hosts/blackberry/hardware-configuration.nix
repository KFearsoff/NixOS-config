{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.initrd.luks.devices."crypt" = {
    device = "/dev/disk/by-partlabel/root";
    bypassWorkqueues = true; # increase SSD performance
    allowDiscards = true; # allow fstrim; it might reveal information about the filesystem
  };
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "subvol=root" "compress-force=zstd" "noatime" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "subvol=home" "compress-force=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress-force=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress-force=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };

  zramSwap.enable = true;
  swapDevices = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
