{
  pkgs,
  config,
  ...
}: [
  {
    command = "${pkgs.autotiling}/bin/autotiling";
    always = true;
  }
  {
    # https://github.com/nix-community/home-manager/issues/2797
    command = "${pkgs.systemd}/bin/systemctl --user try-reload-or-restart kanshi.service";
    always = true;
  }
  {command = "${pkgs.keepassxc}/bin/keepassxc";}
  {command = "${pkgs.ungoogled-chromium}/bin/chromium";}
  {command = "${pkgs.tdesktop}/bin/telegram-desktop";}
  {command = "${config.terminal.binaryPath}";}
  {command = "${pkgs.freetube}/bin/freetube --enable-features=UseOzonePlatform --ozone-platform=wayland";}
  {command = "${pkgs.element-desktop-wayland}/bin/element-desktop";}
  {command = "${pkgs.obsidian}/bin/obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland";}
  {command = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";}
]
