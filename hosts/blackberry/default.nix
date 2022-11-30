{
  inputs,
  pkgs,
  lib,
  config,
  username,
  ...
}: let
  ifname = config.lib.metadata.getInterface config.networking.hostName;
in {
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc
  ];

  sops.secrets.password = {
    sopsFile = ../../secrets/blackberry/default.yaml;
    neededForUsers = true;
  };
  users.users."${username}".passwordFile = config.sops.secrets.password.path;

  hardware.firmware = [
    pkgs.rtl8761b-firmware
  ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  nixchad.boot.bootloader = "grub";
  nixchad.smartctl-exporter.devices = ["/dev/nvme0n1"];
  nixchad.coredns.interface = "br-libvirt";
  nixchad.waybar = {
    backlight = false; # problem with Intel iGPU
    battery = false; # PC, doesn't have a battery
  };
  nixchad.sway.backlight = false;
  nixchad.swayidle.timeouts.lock = 6000;

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
