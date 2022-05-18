{pkgs, ...}: [
  {
    command = "autotiling";
    always = true;
  }
  {command = "keepassxc";}
  {command = "chromium";}
  {command = "telegram-desktop";}
  {command = "alacritty";}
  {command = "freetube --enable-features=UseOzonePlatform --ozone-platform=wayland";}
  {command = "element-desktop";}
  {command = "obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland";}
  {command = "easyeffects --gapplication-service";}
]
