{
  config,
  modulesPath,
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  nixchad.filesystem.type = "ext4";
  networking.wireless.enable = lib.mkForce false;
  nixchad.impermanence.enable = lib.mkForce false;

  environment.systemPackages = [pkgs.chad-bootstrap];
  users.users."${username}".password = "";

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  system.stateVersion = lib.mkForce "22.05";
}
