{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    ../common
    ../common/virtualisation.nix
    ../common/nixconf.nix
    ../common/pipewire.nix
    ../common/syncthing.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc
  ];

  sops.secrets.password = {
    sopsFile = ../../secrets/blackberry/default.yaml;
    neededForUsers = true;
  };
  hardware.firmware = [
    pkgs.rtl8761b-firmware
  ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  networking.hostName = "blackberry"; # Define your hostname.
  nixchad.location = {
    timezone = "Asia/Tbilisi";
    latitude = 41.43;
    longitude = 44.47;
  };

  boot.supportedFilesystems = ["btrfs"];
  services.btrfs.autoScrub.enable = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    device = "nodev";
    efiInstallAsRemovable = true;
  };
  nixchad.coredns.interface = "enp1s0";
}
