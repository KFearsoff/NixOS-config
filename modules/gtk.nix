{pkgs, ...}: {
  enable = true;
  iconTheme.package = pkgs.papirus-icon-theme;
  iconTheme.name = "Papirus-Dark";
  theme.name = "Dracula";
  theme.package = pkgs.dracula-theme;
}
