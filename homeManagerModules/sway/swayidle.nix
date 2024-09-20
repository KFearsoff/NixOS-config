{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.nixchad.swayidle;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  swaypkg = config.wayland.windowManager.sway.package;
in
{
  options.nixchad.swayidle = {
    enable = mkEnableOption "swayidle" // {
      default = osConfig.nixchad.sway.enable;
    };
    timeouts = {
      lock = mkOption {
        type = types.int;
        default = 600;
      };
      screen = mkOption {
        type = types.int;
        default = 1200;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      settings = {
        daemonize = true;
        image = "${../../assets/nix-wallpaper-nineish-dark-gray.png}";
      };
    };

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock";
        }
        {
          event = "lock";
          command = "${pkgs.swaylock}/bin/swaylock";
        }
      ];
      timeouts = [
        {
          timeout = cfg.timeouts.lock;
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = cfg.timeouts.screen;
          command = "${swaypkg}/bin/swaymsg \"output * dpms off\"";
          resumeCommand = "${swaypkg}/bin/swaymsg \"output * dpms on\"";
        }
      ];
    };
  };
}
