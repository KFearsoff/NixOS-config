{
  enable = true;
  events =
    [
      { event = "unlock"; command = "swaymsg \"output * dpms on\""; }
    ];
  timeouts =
    [
      { timeout = 600; command = "swaylock -i ${../../assets/nix-wallpaper-nineish-dark-gray.png}"; }
      #{ timeout = 1200; command = "swaymsg \"output * dpms off\""; }
    ];
}
