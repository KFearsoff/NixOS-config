{ lib, pkgs, ... }:

let wallpaper = ../../assets/nix-wallpaper-nineish-dark-gray.png;
in
{
  enable = true;
  wrapperFeatures.gtk = true;
  config = {
    modifier = "Mod4";
    bindkeysToCode = true;

    input = { "type:keyboard" = import ./keymap.nix; };

    output = {
#      HDMI-A-1 = {
#        pos = "0 0";
#        bg = "${wallpaper} fill";
#      };
      HDMI-A-1 = {
        pos = "0 0";
        bg = "${wallpaper} fill";
      };
      HDMI-A-2 = {
        pos = "1920 0";
        bg = "${wallpaper} fill";
      };
    };

    gaps = { inner = 5; };
    gaps.smartBorders = "on";
    gaps.smartGaps = true;

    bars = [{ command = "waybar"; }];

    colors = import ./colors.nix;
    keybindings = import ./keybindings.nix { inherit lib; inherit pkgs; mod = "Mod4"; };
    startup = import ./startup.nix { inherit pkgs; };
    assigns = import ./assigns.nix;
  };
}
