{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: 
let
  ifname = (import ../default.nix { inherit lib; }).getInterface config.networking.hostName;
in {
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    ../common
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
  networking.bridges."br-libvirt".interfaces = ["${ifname}"];
  networking.networkmanager.unmanaged = ["interface-name:${ifname}" "interface-name:br-libvirt" "interface-name:tailscale0"];
  systemd.services.NetworkManager-wait-online.enable = false;
}
