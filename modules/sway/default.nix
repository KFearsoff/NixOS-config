{ config, lib, pkgs, ... }:

let 
  wallpaper = ../../assets/nix-wallpaper-nineish-dark-gray.png;
in 
  {
    home-manager.users.user.wayland.windowManager.sway.enable = true;
  home-manager.users.user.wayland.windowManager.sway.gtk = true;
  home-manager.users.user.wayland.windowManager.sway.config = {
    modifier = "Mod4";
    bindkeysToCode = true;

    input = { "type:keyboard" = import ./keymap.nix; };

    output = {
#      HDMI-A-1 = {
#        pos = "0 0";
#        bg = "${wallpaper} fill";
#      };
      HDMI-A-2 = {
        pos = "0 0";
        bg = "${wallpaper} fill";
      };
      HDMI-A-3 = {
        pos = "1920 0";
        bg = "${wallpaper} fill";
      };
    };

    gaps = { inner = 5; };
    gaps.smartBorders = "on";
    gaps.smartGaps = true;

    bars = [{ command = "waybar"; }];

    colors = import ./colors.nix { inherit config; };
    keybindings = import ./keybindings.nix { inherit lib pkgs; mod = "Mod4"; };
    startup = import ./startup.nix { inherit pkgs; };
    assigns = import ./assigns.nix;
  };

  home-manager.users.user.wayland.windowManager.sway.extraSessionCommands = ''
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
