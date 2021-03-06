{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.initrd.luks.devices."crypt" = {
    device = "/dev/disk/by-partlabel/root";
    bypassWorkqueues = true; # increase SSD performance
    allowDiscards = true; # allow fstrim; it might reveal information about the filesystem
    preLVM = true; # true by default
  };
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "mode=755"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "ext4";
    options = ["noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/home/nixchad" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
    options = ["noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/persist";
    fsType = "ext4";
    options = ["noatime"];
    neededForBoot = true;
  };

  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;
  swapDevices = [];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
}
