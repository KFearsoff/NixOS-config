{ config, pkgs, ... }:
{
  services.xserver.xkbOptions = "caps:swapescape,grp:alt_shift_toggle";
  console.useXkbConfig = true;
}
