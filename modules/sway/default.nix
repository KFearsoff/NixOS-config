{ lib, pkgs, config, username, ... }:

let
  wallpaper = ../../assets/nix-wallpaper-nineish-dark-gray.png;
  inherit (config.home-manager.users."${username}") colorscheme;
in
{
  config.programs.sway.enable = true;
  config.programs.sway.wrapperFeatures.gtk = true;
  config.programs.sway.extraSessionCommands = ''
    # don't remember, let it be for now
    export DESKTOP_SESSION=sway
    export SDL_VIDEODRIVER=wayland
    export GTK_BACKEND=wayland
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_TYPE=sway
    # Nouveau fix
    export WLR_DRM_NO_MODIFIERS=1
    # required for some Java apps to work on Wayland
    export _JAWA_AWT_WM_NONREPARENTING=1
    # Qt settings
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
  '';
  config.home-manager.users."${username}" = {
    home.packages = [ pkgs.wlogout pkgs.autotiling ];
    wayland.windowManager.sway = {
      enable = true;
      package = null;
      config = {
        modifier = "Mod4";
        bindkeysToCode = true;

        input = {
          "type:keyboard" = import ./keymap.nix;
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
          };
        };
        seat = { "*" = { hide_cursor = "10000"; }; };
        output = { "*" = { bg = "${wallpaper} fill"; }; };

        gaps = { inner = 10; };
        gaps.smartBorders = "on";
        gaps.smartGaps = true;

        bars = [ ];

        colors = import ./colors.nix { inherit colorscheme; };
        keybindings = import ./keybindings.nix { inherit lib pkgs; mod = "Mod4"; };
        startup = import ./startup.nix { inherit pkgs; };
        assigns = import ./assigns.nix;
      };
    };
  };
}
