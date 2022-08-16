# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common
    ../common/nixconf.nix
    ../common/pipewire.nix
    ../common/syncthing.nix
  ];
  programs.openvpn3.enable = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "virtberry"; # Define your hostname.
  sops.secrets.password = {
    sopsFile = ../../secrets/virtberry/default.yaml;
    neededForUsers = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.xkbModel = "pc105";
  services.xserver.displayManager.sddm.settings = {
    Autologin = {
      Session = "plasma.desktop";
      User = "nixchad";
    };
  };
  programs.dconf.enable = true;
  networking.extraHosts = ''
    10.220.32.224 vcenter.lab.itkey.com
    192.168.1.100 blackberry
    10.10.30.9 keycloak-overcloud9.private.infra.devmail.ru
    10.10.30.9 overcloud9.private.infra.devmail.ru
    10.10.30.9 sso-overcloud9.private.infra.devmail.ru
    10.10.30.9 admin-overcloud9.private.infra.devmail.ru
    10.10.30.31 deploy
    10.10.30.191 box2
    10.120.120.166 controller1
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  services.smartd.enable = lib.mkForce false;
  services.fwupd.enable = lib.mkForce false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
