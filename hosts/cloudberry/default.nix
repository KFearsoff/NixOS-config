{
  inputs,
  username,
  lib,
  ...
}: {
  imports = [
    (import ./disko.nix {})
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
  ];

  users.users."${username}".hashedPasswordFile = "/secrets/nixchad-password";
  hm.nixchad.full.enable = false;

  networking.networkmanager.enable = false;
  nixchad = {
    minimal.enable = true;
    hardware.enable = false;
    boot.bootloader = "grub-noefi";
    photoprism.enable = false;

    impermanence.presets = {
      enable = true;
      essential = true;
      system = true;
      services = true;
    };
  };
  zramSwap.enable = true;

  networking = {
    nameservers = lib.mkForce [
      "8.8.8.8"
      "1.1.1.1"
    ];
    useDHCP = false;
    nat.externalInterface = "enp1s0";
  };
  systemd.network = {
    enable = true;
    wait-online.enable = false;

    networks.enp1s0 = {
      matchConfig.Name = "enp1s0";
      gateway = ["172.31.1.1" "fe80::1"];
      address = ["37.27.0.141/32" "2a01:4f9:c012:a517::1/64" "fe80::9400:2ff:fe2e:b2c9/64"];
      routes = [
        {
          routeConfig.Destination = "172.31.1.1";
        }
        {
          routeConfig.Destination = "fe80::1";
        }
      ];
      linkConfig.RequiredForOnline = "routable";
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
  };
}
