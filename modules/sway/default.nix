{ lib, pkgs, colorscheme, ... }:

let
  wallpaper = ../../assets/nix-wallpaper-nineish-dark-gray.png;
in
{
  enable = true;
  wrapperFeatures.gtk = true;
  config = {
    modifier = "Mod4";
    bindkeysToCode = true;

    input = { "type:keyboard" = import ./keymap.nix; };

    output = {
      "*" = {
        bg = "${wallpaper} fill";
      };
    };

    gaps = { inner = 5; };
    gaps.smartBorders = "on";
    gaps.smartGaps = true;

    bars = [{ command = "waybar"; }];

    colors = import ./colors.nix { inherit colorscheme; };
    keybindings = import ./keybindings.nix { inherit lib pkgs; mod = "Mod4"; };
    startup = import ./startup.nix { inherit pkgs; };
    assigns = import ./assigns.nix;
  };

  extraSessionCommands = ''
    # don't remember, let it be for now
    export DESKTOP_SESSION=sway;
    export SDL_VIDEODRIVER=wayland;
    export GTK_BACKEND=wayland;
    export XDG_CURRENT_DESKTOP=sway;
    export XDG_SESSION_TYPE=sway;
    # Nouveau fix
    export WLR_DRM_NO_MODIFIERS=1;
    # required for some Java apps to work on Wayland
    export _JAWA_AWT_WM_NONREPARENTING=1;
    # required for Qt apps to run properly
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1;
    export QT_QPA_PLATFORM=wayland-egl;
  '';
}
