{pkgs, ...}: [
  {
    command = "${pkgs.autotiling}/bin/autotiling";
    always = true;
  }
  {command = "${pkgs.keepassxc}/bin/keepassxc";}
  {command = "${pkgs.ungoogled-chromium}/bin/chromium";}
  {command = "${pkgs.tdesktop}/bin/telegram-desktop";}
  {command = "${pkgs.alacritty}/bin/alacritty";}
  {command = "${pkgs.freetube}/bin/freetube --enable-features=UseOzonePlatform --ozone-platform=wayland";}
  {command = "${pkgs.element-desktop}/bin/element-desktop";}
  {command = "${pkgs.obsidian}/bin/obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland";}
  {command = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";}
]
