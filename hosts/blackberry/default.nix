{ config, pkgs,  ... }:

{
  imports = [ ./hardware-configuration.nix ./swap.nix ];

  networking.hostName = "blackberry"; # Define your hostname.

  # virt-manager
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

#  boot.loader.systemd-boot.enable = true;
#  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];

  virtualisation.docker.enable = true;

  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  # Enable sound.
  sound.enable = true;
#  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixchad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "docker" "video" ];
    initialPassword = "test";
  };
  security.sudo.wheelNeedsPassword = false;

  programs.git.enable = true;
  environment.systemPackages = with pkgs; [
    wget
    htop
    xorg.xkill
    neofetch
    vlc
    notepadqq
    anydesk
    samba
    cifs-utils
    lxqt.lxqt-policykit
    ranger
    cachix
    gnome3.dconf
    tree
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    lxappearance
    virt-manager
    brightnessctl
    wineWowPackages.unstable
    winetricks
    mono
  ];
  programs.qt5ct.enable = true;
  programs.steam.enable = true;
  hardware.opengl.driSupport32Bit = true;
  nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";

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
  system.stateVersion = "21.11"; # Did you read the comment?

}

