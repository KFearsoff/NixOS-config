{ config, pkgs,  ... }:

{
  imports = [ ./hardware-configuration.nix ./home.nix ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    trustedUsers = [ "root" "user" ];
    autoOptimiseStore = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

 # Use the GRUB 2 boot loader
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.devices = [ "nodev" ];
  # NixOS bootsplash
  boot.plymouth.enable = true;

  networking.hostName = "nixos"; # Define your hostname.

  # virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;

  virtualisation.docker.enable = true;

  programs.zsh.enable = true;
  users.users.user.shell = pkgs.zsh;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_CTYPE="en_US.UTF-8";
    LC_NUMERIC="en_US.UTF-8";
    LC_TIME="en_GB.UTF-8";
    LC_COLLATE="en_US.UTF-8";
    LC_MONETARY="en_US.UTF-8";
    LC_MESSAGES="en_US.UTF-8";
    LC_PAPER="en_US.UTF-8";
    LC_NAME="en_US.UTF-8";
    LC_ADDRESS="en_US.UTF-8";
    LC_TELEPHONE="en_US.UTF-8";
    LC_MEASUREMENT="en_US.UTF-8";
    LC_IDENTIFICATION="en_US.UTF-8";
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "test";
  };

  environment.systemPackages = with pkgs; [
    wget
    htop
    xorg.xkill
    neofetch
    vlc
    git
    notepadqq
    anydesk
    samba
    cifs-utils
    lxqt.lxqt-policykit
    ranger
    cachix
    gnome3.dconf
    tree
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "21.05"; # Did you read the comment?

}

