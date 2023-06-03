{
  inputs,
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

  networking.networkmanager.enable = false;
  nixchad.minimal.enable = true;
  nixchad.hardware.enable = false;
  nixchad.boot.bootloader = "grub-noefi";
  nixchad.photoprism.enable = false;
  zramSwap.enable = true;
}
