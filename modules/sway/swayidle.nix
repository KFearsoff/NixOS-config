{
  pkgs,
  ...
}: {
  hm.services.swayidle = {
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
        timeout = 600;
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        timeout = 1200;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
    ];
  };
}
