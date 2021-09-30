{ lib, pkgs, config, inputs, system, ... }:
let
  neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
  #home-manager = import inputs.home-manager.nixosModules.home-manager;
in
  {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = { 
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.user = {
      home = {

  packages = with pkgs; [
      libreoffice
      alacritty 
      i3status
      rofi rofi-pass xsecurelock xautolock xdotool
      gnumake cachix unzip htop
      ungoogled-chromium freetube tdesktop
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
      package = neovim-nightly;
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
  };
};
}
