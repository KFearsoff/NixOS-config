{
  inputs,
  username,
  ...
}:
{
  imports = [
    (import ./disko.nix { })
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
  zramSwap.memoryPercent = 200;

  networking = {
    useDHCP = false;
    nat.externalInterface = "enp1s0";
  };
  systemd.network = {
    enable = true;
    wait-online.enable = false;

    networks.enp1s0 = {
      matchConfig.Name = "enp1s0";
      gateway = [
        "fe80::1"
      ];
      address = [
        "37.27.0.141/32"
        "2a01:4f9:c012:a517::1/64"
      ];
      routes = [
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
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
          PublicKey = "wBQhgyAwAmf/0x166auR1QTMUXZBz8AKlMGSAc4SUSg=";
          AllowedIPs = [
            "192.168.99.0/24"
            "2a01:4f8:c2c:a9a0:7767::/80"
            "2a01:4f9:1a:f600:5650::/80"
          ];
          Endpoint = "4.sosiego.sphalerite.org:23542";
        }
      ];
    };
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = [
        "192.168.99.137/32"
        "2a01:4f8:c2c:a9a0:7767::137/32"
      ];
      routes = [
        {
          Destination = "192.168.99.0/24";
          Scope = "link";
        }
        {
          Destination = "2a01:4f8:c2c:a9a0:7767::/80";
          Scope = "link";
        }
        {
          Destination = "2a01:4f9:1a:f600:5650::/80";
          Scope = "link";
        }
      ];
    };
  };
}
