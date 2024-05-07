{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  imports = [
    ./nushell
    ./terminal.nix
    ./starship.nix
    ./sway
    ./zoxide.nix
  ];

  options.nixchad.full = {
    enable = mkEnableOption "fully customized configuration" // {default = true;};
  };
}
