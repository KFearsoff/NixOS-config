{
  pkgs,
  config,
  ...
}: [
  {
    command = "${pkgs.autotiling}/bin/autotiling -w 1 5 7 8 9";
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
  {command = "${pkgs.freetube}/bin/freetube";}
  {command = "${pkgs.element-desktop-wayland}/bin/element-desktop";}
  {command = "${pkgs.obsidian}/bin/obsidian";}
  {command = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";}
]
