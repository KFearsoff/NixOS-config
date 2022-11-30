{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.swayidle;
in {
  options.nixchad.swayidle = {
    enable = mkEnableOption "swayidle";
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

  config.hm.services.swayidle = mkIf cfg.enable {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f -i ${../../assets/nix-wallpaper-nineish-dark-gray.png}";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f -i ${../../assets/nix-wallpaper-nineish-dark-gray.png}";
      }
    ];
    timeouts = [
      {
        timeout = cfg.timeouts.lock;
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        timeout = cfg.timeouts.screen;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
    ];
  };
}
