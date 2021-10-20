{ config, lib, pkgs, ... }:

{
  fonts = {
    fontconfig = { enable = true; };
    fonts = with pkgs; [
      noto-fonts-cjk 
      noto-fonts
    ];
  };
}
