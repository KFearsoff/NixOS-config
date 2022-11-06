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
    ];
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f -i ${../../assets/nix-wallpaper-nineish-dark-gray.png}";
      }
      {
        timeout = 1200;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
    ];
  };
}
