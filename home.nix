{ lib, pkgs, inputs, system, ... }:
let
  neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
in
rec {
  home.packages = with pkgs; [
      libreoffice
      alacritty 
      i3status
      rofi rofi-pass xsecurelock xautolock xdotool
      gnumake cachix unzip htop
      ungoogled-chromium freetube tdesktop
    ];

  home.file = {
    ".config/i3status/config".source = ./i3status;
  };

  home.keyboard = {
    layout = "us,ru";
    options = [ "grp:alt_shift_toggle" "caps:swapescape" ];
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

    neovim = {
      enable = true;
      package = neovim-nightly;
      viAlias = true;

      plugins = with pkgs.vimPlugins; [
#        vim-airline
#        papercolor-theme
        vim-nix
      ];

#      extraConfig = ''
#        set background=dark
#        colorscheme PaperColor
#      '';
    };
  };

  xsession = {
    enable = true;
    windowManager.i3 = import ./desktop/i3.nix { inherit lib pkgs; };
  };
}
