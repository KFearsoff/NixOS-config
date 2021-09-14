args @ { config, pkgs, lib, ... }:
let
  unstable = config.also.unstable;
in
{
  home = {
    packages = with pkgs; [
      libreoffice
      alacritty i3status
      rofi rofi-pass xsecurelock xautolock xdotool
    ];

  file = {
    ".config/i3status/config".source = ./i3status;
  };

  keyboard = {
    layout = "us,ru";
    options = [ "grp:alt_shift_toggle" ];
  };
};
  
  programs = {
    alacritty = {
      enable = true;
    };

    rofi = {
      enable = true;
      theme = "sidebar";
      terminal = "alacritty";
    };

  home-manager.enable = true;
};

    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        config = import ./i3-config.nix args;
      };
    };
}
