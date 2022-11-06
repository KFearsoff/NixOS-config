{
  config,
  pkgs,
  lib,
  ...
}: with lib; let
  cfg = config.nixchad.assigns;
in {
  options.nixchad.assigns = {
    entries = mkOption {
      type = types.attrs;
      default = {
        "1" = [{app_id = "telegramdesktop";} {app_id = "Element";}];
        "2" = [{app_id = "chromium-browser";}];
        "4" = [{app_id = "FreeTube";}];
        "5" = [{app_id = "org.keepassxc.KeePassXC";}];
        "6" = [{class = "obsidian";}];
        "7" = [
          # General Gaming
          {app_id = "lutris";}
          # Riot Games
          {class = "riotclientux.exe";}
          # LoR
          {class = "Wine";}
          # LoL
          {class = "explorer.exe";}
          {class = "leagueclient.exe";}
          {class = "leagueclientux.exe";}
          {class = "league of legends.exe";}
        ];
      };
    };
  };

  config = {
    hm = { config, ... }: {
      wayland.windowManager.sway.config.assigns = cfg.entries // {"3" = [{app_id = "${config.terminal.windowName}";}];};
    };
  };
}
