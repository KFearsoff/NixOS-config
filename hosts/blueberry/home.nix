{ lib, pkgs, inputs, system, ... }:
let
  neovim = inputs.neovim.packages.${system}.neovim;
in
  {
  home = {

  packages = with pkgs; [
      libreoffice
      alacritty 
      i3status
      rofi rofi-pass xsecurelock xautolock xdotool
      gnumake cachix unzip htop
      ungoogled-chromium freetube tdesktop
      obs-studio
      keepassxc
      obsidian
    ];

  file = {
    ".config/i3status/config".source = ../../i3status;
  };

  keyboard = {
    layout = "us,ru";
    options = [ "grp:alt_shift_toggle" "caps:swapescape" ];
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

    neovim = {
      enable = true;
      package = neovim;
      viAlias = true;
      vimAlias = true;

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
    windowManager.i3 = import ../../desktop/i3.nix { inherit lib pkgs; };
  };

  gtk = import ../../desktop/gtk.nix { inherit pkgs; };
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
}
