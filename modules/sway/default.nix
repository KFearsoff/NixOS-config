{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.sway;
in {
  imports = [
    ./waybar.nix
    ./greetd.nix
  ];

  options.nixchad.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    nixchad.waybar.enable = mkDefault true;
    nixchad.greetd.enable = mkDefault true;
  };
}
