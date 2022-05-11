{ inputs, ... }:

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
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc
  ];

  sops.secrets.password = {
    sopsFile = ../../secrets/blueberry/default.yaml;
    neededForUsers = true;
  };

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

  boot.supportedFilesystems = [ "btrfs" ];
  services.btrfs.autoScrub.enable = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    device = "nodev";
    efiInstallAsRemovable = true;
  };

  programs.steam.enable = true;
  hardware.opengl.driSupport32Bit = true;
  services.flatpak.enable = true;
  nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
}

