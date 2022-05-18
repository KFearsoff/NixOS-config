{
  enable = true;
  events = [
    {
      event = "before-sleep";
      command = "swaylock -f -i ${../../assets/nix-wallpaper-nineish-dark-gray.png}";
    }
  ];
  timeouts = [
    {
      timeout = 600;
      command = "swaylock -f -i ${../../assets/nix-wallpaper-nineish-dark-gray.png}";
    }
    {
      timeout = 1200;
      command = "swaymsg \"output * dpms off\"";
      resumeCommand = "swaymsg \"output * dpms on\"";
    }
  ];
}
