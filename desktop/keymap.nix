{ config, pkgs, ... }:

{
  services.xserver = {
    layout = "us,ru";
    xkbOptions = "caps:swapescape,grp:alt_shift_toggle,eurosign:e";
    autoRepeatDelay = 250;
    autoRepeatInterval = 20;
  };
}
