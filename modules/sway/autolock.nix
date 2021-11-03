{ config, pkgs, ... }:

{
  services.xserver.xautolock = {
    enable = true;
    time = 10; # mins
    killtime = 60; # mins
    killer = "${pkgs.systemd}/bin/systemctl suspend";
  };
}
