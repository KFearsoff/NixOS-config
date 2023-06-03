{
  inputs,
  pkgs,
  config,
  lib,
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
    inputs.hardware.nixosModules.common-hidpi
  ];

  users.users."${username}".passwordFile = "/secrets/nixchad-password";

  hardware.firmware = [
    pkgs.rtl8761b-firmware
  ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
  '';

  nixchad.boot.bootloader = "grub";
  nixchad.smartctl-exporter.devices = ["/dev/nvme0n1"];
  nixchad.waybar = {
    backlight = false; # problem with Intel iGPU
    battery = false; # PC, doesn't have a battery
  };
  nixchad.sway.backlight = false;
  nixchad.swayidle.timeouts.lock = 6000;
  nixchad.restic.usb-backups = true;

  systemd.network = {
    enable = true;

    netdevs."br-libvirt".netdevConfig = {
      Kind = "bridge";
      Name = "br-libvirt";
    };
    networks = {
      "${ifname}" = {
        matchConfig.Name = "${ifname}";
        networkConfig.Bridge = "br-libvirt";
        linkConfig.RequiredForOnline = "enslaved";
      };
      "br-libvirt" = {
        matchConfig.Name = "br-libvirt";
        bridgeConfig = {};
        address = ["192.168.1.104/24"];
        routes = [{routeConfig.Gateway = "192.168.1.1";}];
        linkConfig.RequiredForOnline = "routable";
      };
    };

    wait-online.ignoredInterfaces = ["tailscale0"];
  };
  networking.networkmanager.unmanaged = ["interface-name:${ifname}" "interface-name:br-libvirt" "interface-name:tailscale0"];
  systemd.services.NetworkManager-wait-online.enable = false;

  nix.gc.automatic = lib.mkForce false;
}
