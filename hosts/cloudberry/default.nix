{
  inputs,
  lib,
  username,
  ...
}: {
  imports = [
    (import ./disko.nix {})
    ./networking.nix
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
  ];

  users.users."${username}".passwordFile = "/secrets/nixchad-password";

  networking.networkmanager.enable = lib.mkForce false;
  nixchad.minimal.enable = true;
  nixchad.boot.bootloader = "grub-noefi";
  nixchad.smartctl-exporter.enable = false;
  nixchad.photoprism.enable = false;
  services.smartd.enable = false;
}
