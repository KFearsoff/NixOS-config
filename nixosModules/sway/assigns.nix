{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.assigns;
in {
  options.nixchad.assigns = {
    entries = mkOption {
      type = types.attrs;
      default = {
        "1" = [{app_id = "org.telegram.desktop";} {app_id = "Element";}];
        "2" = [{app_id = "chromium-browser";} {app_id = "firefox";}];
        "4" = [{app_id = "FreeTube";}];
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
          # Steam
          {class = "steam";}
          {class = "Slay the Spire";}
        ];
        "8" = [{app_id = "Slack";}];
      };
    };
  };

  config = {
    hm = {config, ...}: {
      wayland.windowManager.sway.config.assigns = cfg.entries // {"3" = [{app_id = "${config.terminal.windowName}";}];};
    };
  };
}
