args @ { config, pkgs, lib, ... }:
let
  unstable = config.also.unstable;
in
{
  home = {
    packages = with pkgs; [
      libreoffice
      alacritty i3status
    ];

  file = {
    ".config/i3status/config".source = ./i3status;
  };
  };
  
  programs = {
    alacritty = {
      enable = true;
    };

  home-manager.enable = true;
};

    xsession.windowManager.i3 = {
      package = pkgs.i3-gaps;
      config = import ./i3-config.nix args;
    };
}
