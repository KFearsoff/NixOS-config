{ pkgs, ... }:

{
  imports = [
    ./fonts.nix
  ];

  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      greeter.enable = true;
      greeters.gtk = {
        iconTheme.package = pkgs.paper-icon-theme;
        iconTheme.name = "Paper";
        theme.package = pkgs.adapta-gtk-theme;
        theme.name = "Adapta-Nokto-Eta";
      };
    };
  };

  programs.sway = {
    enable = true;
#    wrapperFeatures.gtk = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      gtkUsePortal = true;
    };
  };
}
