{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.waybar;
in
{
  options.nixchad.waybar = {
    enable = mkEnableOption "waybar";
    backlight = mkEnableOption "backlight info";
    battery = mkEnableOption "battery info";
  };

  config = mkIf cfg.enable {
    nixchad.waybar.backlight = mkDefault true;
    nixchad.waybar.battery = mkDefault false;

    hm = {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        systemd.target = "sway-session.target";
      };
    };
  };
}
