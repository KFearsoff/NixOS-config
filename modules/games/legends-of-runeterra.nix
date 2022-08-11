{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.games;
in {
  options.nixchad.games = {
    legends-of-runeterra.enable = mkEnableOption "Legends of Runeterra";
  };

  config = mkIf cfg.legends-of-runeterra.enable {
    nixchad.games.lutrisPackages = with pkgs; [openssl wineWowPackages.full];

    home-manager.users."${username}".xdg.desktopEntries = {
      LoR = {
        name = "Legends of Runeterra";
        genericName = "A Riot game";
        exec = "env LUTRIS_SKIP_INIT=1 ${pkgs.lutris}/bin/lutris lutris:rungame/legends-of-runeterra";
      };
    };
  };
}
