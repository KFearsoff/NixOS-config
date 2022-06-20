{
  username,
  pkgs,
  ...
}: {
  home-manager.users."${username}" = {
    home.packages = [pkgs.myteam];
    xdg.desktopEntries = {
      myteam = {
        name = "My Team";
        genericName = "Corporate Messenger";
        exec = "env QT_QPA_PLATFORM=xcb ${pkgs.myteam}/bin/myteam";
      };
    };
  };
}
