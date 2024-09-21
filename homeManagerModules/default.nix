{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./nushell
    ./terminal.nix
    ./starship.nix
    ./sway
    ./zoxide.nix
    ./cli
    ./gui
  ];

  options.nixchad.full = {
    enable = mkEnableOption "fully customized configuration" // {
      default = true;
    };
  };
}
