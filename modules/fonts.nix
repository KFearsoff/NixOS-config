{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultFonts = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Iosevka" ];
        emoji = [ "Iosevka" ];
        monospace = [ "Iosevka" ];
        sansSerif = [ "Iosevka" ];
      };
    };
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
      vistafonts
      corefonts
    ];
  };
}
