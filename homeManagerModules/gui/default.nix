{ config, lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./vscodium.nix
  ];

  options.nixchad.gui = {
    enable = mkEnableOption "gui programs" // {
      default = config.nixchad.full.enable;
    };
  };
}
