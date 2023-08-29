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
    backlight = mkOption {
      type = types.bool;
      description = "Whether to enable backlight controls";
      default = true;
    };
    modifier = mkOption {
      type = types.str;
      default = "Mod4";
    };
  };

  config = mkIf cfg.enable {
    nixchad.swayidle.enable = mkDefault true;

    security.polkit.enable = true;
    hardware.opengl.enable = true;
    programs.dconf.enable = true;
    programs.light.enable = lib.mkDefault true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];

    hm = {config, ...}: {
      home.packages = [pkgs.wl-clipboard];

      home.pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
        gtk.enable = true;
      };

      wayland.windowManager.sway = {
        enable = true;
        systemd.xdgAutostart = true;
        wrapperFeatures.gtk = true;
        extraSessionCommands = ''
          NIXOS_OZONE_WL=1
          MOZ_ENABLE_WAYLAND=1
          # Qt5
          export QT_QPA_PLATFORM=wayland-egl
          export QT_AUTO_SCREEN_SCALE_FACTOR=1 # QT_WAYLAND_FORCE_DPI=physical forces some Qt apps to scale twice, is undesirable
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          # required for some Java apps to work on Wayland
          export _JAWA_AWT_WM_NONREPARENTING=1
          # don't remember, let it be for now
          export DESKTOP_SESSION=sway
          export XDG_CURRENT_DESKTOP=sway
          export XDG_SESSION_TYPE=sway
        '';

        config = {
          inherit (cfg) modifier;
          bindkeysToCode = true;
          window.titlebar = false;
          floating.titlebar = false;

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
