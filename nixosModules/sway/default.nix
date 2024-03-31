{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  wallpaper = ../../assets/nix-wallpaper-nineish-dark-gray.png;
  inherit (config.hm) colorScheme;
  cfg = config.nixchad.sway;
in {
  imports = [
    ./waybar.nix
    ./greetd.nix
    ./mako.nix
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
    security.polkit.enable = true;
    security.pam.services.swaylock = {};
    hardware.opengl.enable = true;
    programs.dconf.enable = true;
    programs.light.enable = lib.mkDefault true;

    hm = {config, ...}: {
      home.packages = [pkgs.wl-clipboard pkgs.grim];

      services.swayosd.enable = true;
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];
        xdgOpenUsePortal = true;
        config.sway.default = ["wlr" "gtk"];
      };

      services.flameshot.enable = true;

      wayland.windowManager.sway = {
        enable = true;
        systemd.xdgAutostart = true;
        wrapperFeatures.gtk = true;
        extraSessionCommands = ''
          export NIXOS_OZONE_WL=1
          export MOZ_ENABLE_WAYLAND=1
          # Qt5
          export QT_QPA_PLATFORM=wayland-egl
          export QT_AUTO_SCREEN_SCALE_FACTOR=1 # QT_WAYLAND_FORCE_DPI=physical forces some Qt apps to scale twice, is undesirable
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          # required for some Java apps to work on Wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
          # don't remember, let it be for now
          export DESKTOP_SESSION=sway
          export XDG_CURRENT_DESKTOP=sway
          export XDG_SESSION_TYPE=sway
        '';

        config = {
          inherit (cfg) modifier;
          bindkeysToCode = true;
          floating.titlebar = false;

          input = import ./input.nix;
          seat = {"*" = {hide_cursor = "10000";};};
          output = {"*" = {bg = "${wallpaper} fill";};};

          window = {
            titlebar = false;
            commands = [
              {
                command = "floating enable, border none, resize set 450 400, move position 1470 0";
                criteria = {
                  title = "^Syncthing Tray( \(.*\))?$";
                };
              }
              {
                command = "border pixel 0, floating enable, fullscreen disable, move absolute position 0 0";
                criteria = {
                  app_id = "flameshot";
                };
              }
            ];
          };

          gaps = {inner = 10;};
          gaps.smartBorders = "on";
          gaps.smartGaps = true;

          bars = [];

          focus.wrapping = "force";
          workspaceAutoBackAndForth = true;
          menu = "rofi -show drun";
          terminal = "${config.terminal.binaryPath}";

          colors = import ./colors.nix {inherit colorScheme;};
        };
      };
    };
  };
}
