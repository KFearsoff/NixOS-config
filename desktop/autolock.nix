{ config, pkgs, ... }:

{
  services.xserver.xautolock = {
    enable = true;
    time = 10; # mins
    killtime = 30; # mins
    killer = "${pkgs.systemd}/bin/systemctl suspend";
  };
}
