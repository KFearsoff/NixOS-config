{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];
      luks.devices."crypt" = {
        device = "/dev/disk/by-partlabel/root";
        bypassWorkqueues = true; # increase SSD performance
        allowDiscards = true; # allow fstrim; it might reveal information about the filesystem
      };
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = ["subvol=root" "compress-force=zstd" "noatime"];
    };

    "/home/nixchad" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = ["subvol=home-nixchad" "compress-force=zstd" "noatime"];
    };

    "/nix" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = ["subvol=nix" "compress-force=zstd" "noatime"];
    };

    "/persist" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = ["subvol=persist" "compress-force=zstd" "noatime"];
      neededForBoot = true;
    };

    "/secrets" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = ["subvol=secrets" "compress-force=zstd" "noatime"];
      neededForBoot = true;
    };

    "/swap" = {
      device = "/dev/disk/by-label/root";
      fsType = "btrfs";
      options = ["subvol=swap" "noatime"];
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };
  };

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8196;
    }
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
