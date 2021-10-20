{ config, lib, pkgs, ... }:

{
  fonts = {
    #enableDefaultFonts = true;
    fontconfig = { enable = true; };

    fonts = with pkgs; [
      noto-fonts-cjk 
      noto-fonts
    ];
  };
}
