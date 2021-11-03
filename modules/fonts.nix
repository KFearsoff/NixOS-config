{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultFonts = true;
    fontconfig = { 
      enable = true;
      defaultFonts = {
        serif = [ "Iosevka" ];
        emoji = [ "Iosevka" ];
        monospace = [ "Iosevka Term" ];
        sansSerif = [ "Iosevka Slab" ];
      };
    };
    fonts = with pkgs; [
      nerdfonts
    ];
  };
}
