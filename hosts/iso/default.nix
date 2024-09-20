{
  modulesPath,
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
  ];
  nixchad = {
    system.enable = lib.mkForce false;
    impermanence.enable = lib.mkForce false;
    networking.enable = lib.mkForce false;
    boot.enable = lib.mkForce false;
    filesystem.enable = lib.mkForce false;
  };

  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = true;

  environment.systemPackages = [ pkgs.git ];
  users.users."${username}".password = "";

  system.stateVersion = lib.mkForce "23.11";
}
