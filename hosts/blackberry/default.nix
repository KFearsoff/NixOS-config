{
  inputs,
  pkgs,
  config,
  username,
  ...
}: let
  ifname = config.lib.metadata.getInterface config.networking.hostName;
in {
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc
  ];

  users.users."${username}".passwordFile = "/secrets/nixchad-password";

  hardware.firmware = [
    pkgs.rtl8761b-firmware
  ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  nixchad.boot.bootloader = "grub";
  nixchad.smartctl-exporter.devices = ["/dev/nvme0n1"];
  nixchad.waybar = {
    backlight = false; # problem with Intel iGPU
    battery = false; # PC, doesn't have a battery
  };
  nixchad.sway.backlight = false;
  nixchad.swayidle.timeouts.lock = 6000;

  networking.bridges."br-libvirt".interfaces = ["${ifname}"];
  networking.networkmanager.unmanaged = ["interface-name:${ifname}" "interface-name:br-libvirt" "interface-name:tailscale0"];
  systemd.services.NetworkManager-wait-online.enable = false;
}
