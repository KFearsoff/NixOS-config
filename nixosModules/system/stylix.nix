{pkgs, ...}: let
  firaCode = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
in {
  stylix = {
    enable = true;
    image = ../../assets/nix-wallpaper-nineish-dark-gray.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    # polarity = "dark";
    fonts = {
      serif = {
        package = firaCode;
        name = "FiraCode Nerd Font";
      };
      sansSerif = {
        package = firaCode;
        name = "FiraCode Nerd Font";
      };
      monospace = {
        package = firaCode;
        name = "FiraCode Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  fonts.packages = [
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
  ];

  hm = {config, ...}: {
    gtk = {
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
      gtk2 = {
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        extraConfig = ''
          gtk-alternative-button-order = 1
        '';
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-decoration-layout = "icon:minimize,maximize,close";
      };
      gtk4.extraConfig = {
        color-scheme = "prefer-dark";
        gtk-decoration-layout = "icon:minimize,maximize,close";
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };
  };
}
