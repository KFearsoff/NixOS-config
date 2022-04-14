{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    ../common
    ../common/virtualisation.nix
    ../common/nixconf.nix
    ../common/pipewire.nix
    ../common/syncthing.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-acpi_call
  ];

  networking = {
    hostName = "blueberry"; # Define your hostname.
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.dconf.enable = true;
  programs.light.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  security.sudo.wheelNeedsPassword = false;

  services.printing.enable = true;
  users.mutableUsers = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

