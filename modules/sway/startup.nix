{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.startup;
in {
  options.nixchad.startup = {
    entries = mkOption {
      type = types.listOf types.attrs;
      default = [
        {command = "${pkgs.keepassxc}/bin/keepassxc";}
        {command = "${pkgs.ungoogled-chromium}/bin/chromium";}
        {command = "${pkgs.tdesktop}/bin/telegram-desktop";}
        {command = "${pkgs.freetube}/bin/freetube";}
        {command = "${pkgs.element-desktop-wayland}/bin/element-desktop";}
        {command = "${pkgs.obsidian}/bin/obsidian";}
        {command = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";}
        {command = "${pkgs.slack}/bin/slack";}
      ];
    };

    autotiling = mkEnableOption "autotiling";
    kanshi = mkEnableOption "kanshi";
  };

  config = {
    nixchad.startup.autotiling = mkDefault true;
    nixchad.startup.kanshi = mkDefault true;

    hm = {config, ...}: {
      wayland.windowManager.sway.config.startup =
        cfg.entries
        ++ optional cfg.autotiling {
          command = "${pkgs.autotiling}/bin/autotiling -w 1 5 7 8 9";
          always = true;
        }
        ++ optional cfg.kanshi {
          # https://github.com/nix-community/home-manager/issues/2797
          command = "${pkgs.systemd}/bin/systemctl --user try-reload-or-restart kanshi.service";
          always = true;
        }
        ++ [{command = "${config.terminal.binaryPath}";}];
    };
  };
}
