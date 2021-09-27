{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [
      noto-fonts-cjk 
    ];
  };
}
