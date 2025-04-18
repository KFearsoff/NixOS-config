{
  inputs,
  username,
  ...
}:
{
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
    smartctl-exporter.devices = [ "/dev/nvme0n1" ];
    waybar = {
      backlight = false; # PC GPUs don't do that
      battery = false; # PC, doesn't have a battery
    };
    restic.usb-backups = true;

    impermanence.presets = {
      enable = true;
      essential = true;
      system = true;
      services = true;
    };
  };
  programs.light.enable = false;

  networking = {
    networkmanager.enable = true;
  };
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
    networks = {
      wg0 = {
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

    wait-online.ignoredInterfaces = [ "tailscale0" ];
  };
  hm.nixchad = {
    gui.enable = true;
    swayidle.timeouts.lock = 6000;
  };
}
