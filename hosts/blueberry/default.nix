# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs,  ... }:

{
#  imports = 
#    [
#      (modulesPath + "/installer/scan/not-detected.nix")
#    ];
#  
#  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
#  boot.initrd.kernelModules = [ ];
#  boot.kernelModules = [ "kvm-intel" ];
#  boot.extraModulePackages = [ ];
#  
#  fileSystems."/" = {
#    device = "/dev/disk/by-label/nixos";
#    fsType = "ext4";
#  };
#  
#  fileSystems."/boot" = {
#    device = "/dev/disk/by-label/boot";
#    fsType = "vfat";
#  };
#
#  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
#
#  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    trustedUsers = [ "root" "user" ];
    autoOptimiseStore = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # # Use the systemd-boot EFI boot loader
#  boot.loader.systemd-boot.enable = true;
#  boot.loader.efi.canTouchEfiVariables = true;
  # Use the GRUB 2 boot loader
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.devices = [ "nodev" ];
  # NixOS bootsplash
  boot.plymouth.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.docker.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xautolock = {
    enable = true;
    time = 10; # mins
    killtime = 30; # mins
    killer = "${pkgs.systemd}/bin/systemctl suspend";
  };
  services.xserver.displayManager.lightdm = {
    enable = true;
    greeter.enable = true;
    greeters.gtk = {
      iconTheme.package = pkgs.paper-icon-theme;
      iconTheme.name = "Paper";
      theme.package = pkgs.adapta-gtk-theme;
      theme.name = "Adapta-Nokto-Eta";
    };
  };
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };
  services.xserver.desktopManager.plasma5.enable = true;
  

  # Configure keymap in X11
  services.xserver.layout = "us,ru";
  services.xserver.xkbOptions = "caps:swapescape,grp:alt_shift_toggle,eurosign:e";
  services.xserver.autoRepeatDelay = 250;
  services.xserver.autoRepeatInterval = 20;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "test";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    qutebrowser
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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

