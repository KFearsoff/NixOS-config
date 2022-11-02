{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.graphical;
in {
  imports = [
    ./office.nix
  ];

  options.nixchad.graphical = {
    enable = mkEnableOption "graphical session";
  };
}
