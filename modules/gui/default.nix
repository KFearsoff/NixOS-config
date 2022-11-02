{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.gui;
in {
  imports = [
    ./office.nix
    ./graphics.nix
    ./vscodium.nix
  ];

  options.nixchad.gui = {
    enable = mkEnableOption "gui programs";
  };
}
