{ lib, pkgs, ... }:

{
  enable = true;
  wrapperFeatures.gtk = true;
  config = {
    modifier = "Mod4";
    bindkeysToCode = true;

    input = { "type:keyboard" = import ./keymap.nix; };

    output = {
      HDMI-A-1 = {
        pos = "0 0";
        bg = "/home/user/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png fill";
      };
      HDMI-A-2 = {
        pos = "1920 0";
        bg = "/home/user/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png fill";
      };
    };

    gaps = { inner = 5; };
    gaps.smartBorders = "on";
    gaps.smartGaps = true;

    # bars = import ./waybar.nix;
    bars = [{ command = "waybar"; }];

    colors = import ./colors.nix;

    keybindings = import ./keybindings.nix { inherit lib; inherit pkgs; mod = "Mod4"; };

    startup = import ./startup.nix { inherit pkgs; };
    assigns = import ./assigns.nix;
  };
}
