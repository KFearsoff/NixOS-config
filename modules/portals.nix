{ pkgs, ... }:

{
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        #xdg-desktop-portal-kde
      ];
      wlr.enable = true; # installs the xdg-desktop-portal-wlr
      gtkUsePortal = true; # only sets GTK_USE_PORTAL=1, doesn't install the portal itself
    };
  };
}
