{
  inputs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    (import ./disko.nix {})
    inputs.disko.nixosModules.disko
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-hidpi
  ];
  services.thermald.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  users.users."${username}".hashedPasswordFile = "/secrets/nixchad-password";

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Focusrite Scarlett 2i2
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
  '';
  nixchad = {
    boot.bootloader = "systemd-boot";
    restic.usb-backups = true;
    smartctl-exporter.devices = ["/dev/nvme0n1"];
    waybar.battery = true;
    impermanence = {
      presets = {
        enable = true;
        essential = true;
        system = true;
        services = true;
      };

      persisted.values = [
        {
          directories = [
            {
              directory = "/var/lib/bluetooth";
              mode = "0700";
            }
          ];
        }
      ];
    };
  };
  programs.light.enable = true;
  programs.openvpn3.enable = true;

  systemd.network = {
    enable = true;

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

    wait-online.enable = false;
  };

  networking.networkmanager.unmanaged = ["interface-name:tailscale0" "interface-name:tun*"];
  zramSwap.enable = true;
}
