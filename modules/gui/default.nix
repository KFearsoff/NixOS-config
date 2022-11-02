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
  ];

  options.nixchad.gui = {
    enable = mkEnableOption "gui programs";
  };
}
