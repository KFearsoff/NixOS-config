{ ... }:

{
  imports = [
    ../modules/fonts.nix
    ../modules/grub-efi.nix
    ../modules/sddm.nix
    ../modules/locale.nix
    ../modules/nixconfig.nix
  ];
}
