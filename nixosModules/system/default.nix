{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.nixchad.system;
in
{
  imports = [
    ./containers.nix
    ./libvirt.nix
    ./location.nix
    ./nixconf.nix
    ./impermanence.nix
    ./networking.nix
    ./boot.nix
    ./filesystem.nix
    ./stylix.nix
    ./tty.nix
    ./minimal.nix
    ./hardware.nix
    ./ssh.nix
  ];

  options.nixchad.system = {
    enable = mkEnableOption "system";
  };

  config = mkIf cfg.enable {
    nixchad = {
      impermanence.enable = mkDefault true;
      networking.enable = mkDefault true;
      boot.enable = mkDefault true;
      filesystem.enable = mkDefault true;
      hardware.enable = mkDefault true;
    };

    users.mutableUsers = false;

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    security.sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false;
    };
    users.users."${username}".openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQ77pbUwzNYJzu/vEg9MqtuLQmjgRtf5b4K+qsZ0o7v nixchad@blackberry"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN8XLDGBt0tt28PfY7O10WZJV793SUU3veDLkufyMKh7 github-action"
    ];

    services.journald.extraConfig = "SystemMaxUse=100M";

    systemd = {
      oomd.enable = true;

      slices = {
        "root".sliceConfig = {
          # Start throttling things, and possibly trigger oomd at 90% usage
          MemoryHigh = "90%";
        };

        "system".sliceConfig = {
          ManagedOOMMemoryPressure = "kill";
          ManagedOOMMemoryPressureLimit = "60%";
        };
        "user".sliceConfig = {
          ManagedOOMMemoryPressure = "kill";
          ManagedOOMMemoryPressureLimit = "40%";
        };
      };

      # Never kill the sshd service. We need that one :)
      services."sshd".serviceConfig = {
        MemoryMin = "50M";
        ManagedOOMPreference = "omit";
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = lib.mkDefault "23.11"; # Did you read the comment?
  };
}
