{
  inputs,
  username,
  lib,
  ...
}: let
  ifname = "enp4s0";
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

  users.users."${username}".hashedPasswordFile = "/secrets/nixchad-password";

  # hardware.firmware = [
  #   pkgs.rtl8761b-firmware
  # ];
  # hardware.bluetooth.enable = true;
  # services.blueman.enable = true;

  # Focusrite Scarlett 2i2
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
  '';
  nixchad = {
    boot.bootloader = "grub";
    smartctl-exporter.devices = ["/dev/nvme0n1"];
    waybar = {
      backlight = false; # PC GPUs don't do that
      battery = false; # PC, doesn't have a battery
    };
    swayidle.timeouts.lock = 6000;
    restic.usb-backups = true;
    firefox.enable = lib.mkForce false;

    impermanence.presets = {
      enable = true;
      essential = true;
      system = true;
      services = true;
    };
  };
  programs.light.enable = false;

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
    netdevs."10-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };
      wireguardConfig = {
        PrivateKeyFile = "/secrets/wg-private";
      };
      wireguardPeers = [
        {
          wireguardPeerConfig = {
            PublicKey = "wBQhgyAwAmf/0x166auR1QTMUXZBz8AKlMGSAc4SUSg=";
            AllowedIPs = ["192.168.99.0/24" "2a01:4f8:c2c:a9a0:7767::/80" "2a01:4f9:1a:f600:5650::/80"];
            Endpoint = "4.sosiego.sphalerite.org:23542";
          };
        }
      ];
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = ["192.168.99.137/32" "2a01:4f8:c2c:a9a0:7767::137/32"];
      routes = [
        {
          routeConfig.Destination = "192.168.99.0/24";
          routeConfig.Scope = "link";
        }
        {
          routeConfig.Destination = "2a01:4f8:c2c:a9a0:7767::/80";
          routeConfig.Scope = "link";
        }
        {
          routeConfig.Destination = "2a01:4f9:1a:f600:5650::/80";
          routeConfig.Scope = "link";
        }
      ];
    };

    wait-online.ignoredInterfaces = ["tailscale0" "wg0"];
  };
  networking.networkmanager.unmanaged = ["interface-name:${ifname}" "interface-name:br-libvirt" "interface-name:tailscale0" "interface-name:tun*"];
  systemd.services.NetworkManager-wait-online.enable = false;
}
