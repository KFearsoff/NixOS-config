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
}
