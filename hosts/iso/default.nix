{
  modulesPath,
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
  ];

  nixchad.system.enable = lib.mkForce false;
  nixchad.impermanence.enable = lib.mkForce false;
  nixchad.networking.enable = lib.mkForce false;
  nixchad.boot.enable = lib.mkForce false;
  nixchad.filesystem.enable = lib.mkForce false;
  nixchad.colors.enable = lib.mkForce false;

  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = true;

  environment.systemPackages = [pkgs.git];
  users.users."${username}".password = "";

  system.stateVersion = lib.mkForce "22.11";
}
