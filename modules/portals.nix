{ pkgs, ... }:

{
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        libsForQt5.xdg-desktop-portal-kde
      ];
      wlr.enable = true;
      gtkUsePortal = true;
    };
  };
}
