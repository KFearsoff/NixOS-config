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

  users.users."${username}".passwordFile = "/secrets/nixchad-password";

  networking.networkmanager.enable = false;
  nixchad.minimal.enable = true;
  nixchad.hardware.enable = false;
  nixchad.boot.bootloader = "grub-noefi";
  nixchad.photoprism.enable = false;
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
  };

  nixchad.impermanence.presets = {
    enable = true;
    essential = true;
    system = true;
    services = true;
  };
}
