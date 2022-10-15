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
  nixchad.smartctl-exporter.devices = ["/dev/nvme0n1"];
  nixchad.coredns.interface = "br-libvirt";

  networking.interfaces."br-libvirt".ipv4.addresses = [
    {
      address = "192.168.0.104";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.0.1";
  networking.bridges."br-libvirt".interfaces = ["enp1s0"];
  networking.networkmanager.unmanaged = ["interface-name:enp1s0" "interface-name:br-libvirt" "interface-name:tailscale0"];
  systemd.services.NetworkManager-wait-online.enable = false;
}
