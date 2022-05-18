{
  username,
  pkgs,
  ...
}: {
  config.home-manager.users."${username}" = {
    gtk = {
      enable = true;
      iconTheme.package = pkgs.papirus-icon-theme;
      iconTheme.name = "Papirus-Dark";
      theme.name = "Dracula";
      theme.package = pkgs.dracula-theme;
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "gtk2";
    };
  };
}
