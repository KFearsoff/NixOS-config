{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common
    ../common/swap-btrfs.nix
    ../common/virtualisation.nix
    ../common/nixconf.nix
    ../common/pipewire.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc
  ];

  networking = {
    hostName = "blackberry"; # Define your hostname.
    interfaces.enp108s0.ipv4.addresses = [{
      address = "192.168.1.100";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
    firewall.checkReversePath = false;
  };

  programs.dconf.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  services.btrfs.autoScrub.enable = true;

  security.sudo.wheelNeedsPassword = false;

  programs.steam.enable = true;
  hardware.opengl.driSupport32Bit = true;
  services.flatpak.enable = true;
  nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";

  # Enable the OpenSSH daemon.
  programs.ssh.startAgent = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

