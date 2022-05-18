{
  username,
  pkgs,
  config,
  lib,
  ...
}: let
  wallpaper = ../../assets/nix-wallpaper-nineish-dark-gray.png;
  inherit (config.home-manager.users."${username}") colorscheme;
in {
  imports = [./swayidle.nix];

  config = {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        MOZ_ENABLE_WAYLAND=1
        # Qt5
        export QT_QPA_PLATFORM=wayland-egl
        export QT_AUTO_SCREEN_SCALE_FACTOR=1 # QT_WAYLAND_FORCE_DPI=physical forces some Qt apps to scale twice, is undesirable
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        # Elementary/EFL
        ECORE_EVAS_ENGINE=wayland_egl
        ELM_ENGINE=wayland_egl
        # SDL
        export SDL_VIDEODRIVER=wayland
        # required for some Java apps to work on Wayland
        export _JAWA_AWT_WM_NONREPARENTING=1
        # don't remember, let it be for now
        export DESKTOP_SESSION=sway
        export GTK_BACKEND=wayland
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE=sway
        # Nouveau fix
        export WLR_DRM_NO_MODIFIERS=1
      '';
    };

    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        swaylock
        wl-clipboard
        mako
        sway-contrib.grimshot
      ];

      home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

      wayland.windowManager.sway = {
        enable = true;
        package = null;
        config = {
          modifier = "Mod4";
          bindkeysToCode = true;

          input = import ./input.nix;
          seat = {"*" = {hide_cursor = "10000";};};
          output = {"*" = {bg = "${wallpaper} fill";};};

          gaps = {inner = 10;};
          gaps.smartBorders = "on";
          gaps.smartGaps = true;

          bars = [];

          colors = import ./colors.nix {inherit colorscheme;};
          keybindings = import ./keybindings.nix {
            inherit lib pkgs;
            mod = "Mod4";
          };
          startup = import ./startup.nix {inherit pkgs;};
          assigns = import ./assigns.nix;
        };
      };
    };
  };
}
