{ pkgs, ... }:

{
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        libsForQt5.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
      wlr.enable = true;
      gtkUsePortal = true;
    };
  };
}
