{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  wallpaper = ../../assets/nix-wallpaper-nineish-dark-gray.png;
  inherit (config.hm) colorscheme;
  cfg = config.nixchad.sway;
in {
  imports = [
    ./waybar.nix
    ./greetd.nix
    ./mako.nix
    ./swayidle.nix
    ./keybindings.nix
    ./startup.nix
    ./assigns.nix
  ];

  options.nixchad.sway = {
    enable = mkEnableOption "sway";
    backlight = mkEnableOption "backlight controls";
    modifier = mkOption {
      type = types.str;
      default = "Mod4";
    };
  };

  config = mkIf cfg.enable {
    nixchad.sway.backlight = mkDefault true;
    nixchad.swayidle.enable = mkDefault true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    security.polkit.enable = true;
    security.pam.services.swaylock = {};
    hardware.opengl.enable = lib.mkDefault true;
    fonts.enableDefaultFonts = lib.mkDefault true;
    programs.dconf.enable = lib.mkDefault true;
    programs.light.enable = lib.mkDefault true;
    xdg.portal = {
      enable = true;
      wlr.enable = true; # installs xdg-desktop-portal-wlr
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    hm = {config, ...}: {
      home.packages = [pkgs.wl-clipboard];

      home.pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
        gtk.enable = true;
      };

      wayland.windowManager.sway = {
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

        config = {
          inherit (cfg) modifier;
          bindkeysToCode = true;

          input = import ./input.nix;
          seat = {"*" = {hide_cursor = "10000";};};
          output = {"*" = {bg = "${wallpaper} fill";};};

          gaps = {inner = 10;};
          gaps.smartBorders = "on";
          gaps.smartGaps = true;

          bars = [];

          focus.wrapping = "force";
          workspaceAutoBackAndForth = true;
          menu = "rofi -show drun";
          terminal = "${config.terminal.binaryPath}";

          colors = import ./colors.nix {inherit colorscheme;};
        };
      };
    };
  };
}
