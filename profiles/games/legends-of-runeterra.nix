{
  username,
  pkgs,
  ...
}: {
  home-manager.users."${username}".xdg.desktopEntries = {
    LoR = {
      name = "Legends of Runeterra";
      genericName = "A Riot game";
      exec = "env LUTRIS_SKIP_INIT=1 ${pkgs.lutris}/bin/lutris lutris:rungame/legends-of-runeterra";
    };
  };
}
