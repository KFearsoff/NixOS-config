{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.graphical;
in {
  options.nixchad.graphical = {
    enable = mkEnableOption "graphical session";
  };
}
