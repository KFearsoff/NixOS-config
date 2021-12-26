{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultFonts = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Iosevka Term Slab" ];
        emoji = [ "Iosevka Term" ];
        monospace = [ "Iosevka Term" ];
        sansSerif = [ "Iosevka Term" ];
      };
    };
    fonts = with pkgs; [
      nerdfonts
    ];
  };
}
