{lib, ...}: let
  inherit (lib) mkDefault;
in {
  imports = [
    ./nushell
    ./terminal.nix
  ];

  nixchad.nushell.enable = mkDefault true;
}
