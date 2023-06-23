{
  inputs,
  config,
  lib,
  username,
  ...
}: let
  ifname = config.lib.metadata.getInterface config.networking.hostName;
in {
  imports = [
    ./hardware-configuration.nix
    # ./kanshi.nix
    (import ./disko.nix {})
    inputs.disko.nixosModules.disko
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-hidpi
  ];

  users.users."${username}".passwordFile = "/secrets/nixchad-password";

  # Focusrite Scarlett 2i2
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
  '';

  nixchad.boot.bootloader = "systemd-boot";
  nixchad.smartctl-exporter.devices = ["/dev/nvme0n1"];
  programs.light.enable = true;
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
        address = ["192.168.1.201/24"];
        routes = [{routeConfig.Gateway = "192.168.1.1";}];
        linkConfig.RequiredForOnline = "routable";
      };
    };

    wait-online.ignoredInterfaces = ["tailscale0"];
  };
  networking.networkmanager.unmanaged = ["interface-name:${ifname}" "interface-name:br-libvirt" "interface-name:tailscale0" "interface-name:tun*"];
  systemd.services.NetworkManager-wait-online.enable = false;
  zramSwap.enable = true;
}
