{ pkgs, ... }:
{
  enable = true;
  font.name = "Noto Sans";
  iconTheme.package = pkgs.papirus-icon-theme;
  iconTheme.name = "Papirus Dark";
  theme.name = "Adapta-Nokto-Eta";
  theme.package = pkgs.adapta-gtk-theme;
  gtk2.extraConfig = ''
    gtk-cursor-theme-size=0
    gtk-toolbar-style=GTK_TOOLBAR_BOTH
    gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
    gtk-button-images=1
    gtk-menu-images=1
    gtk-enable-event-sounds=1
    gtk-enable-input-feedback-sounds=1
    gtk-xft-antialias=1
    gtk-xft-hinting=1
    gtk-xft-hintstyle=hintfull
    gtk-xft-rgba=rgb'';
  gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = "0";
    gtk-cursor-theme-name = "Paper";
    gtk-cursor-theme-size = "0";
    gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
    gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
    gtk-button-images = "1";
    gtk-menu-images = "1";
    gtk-enable-event-sounds = "0";
    gtk-enable-input-feedback-sounds = "0";
    gtk-xft-antialias = "1";
    gtk-xft-hinting = "1";
    gtk-xft-hintstyle = "hintfull";
    gtk-xft-rgba = "rgb";
  };
  gtk3.extraCss = ''
    window decoration {
      margin: 0;
      border: none;
    }
    /* regular thunar toolbar icons */
    .thunar {
      -gtk-icon-style: regular;
    }
  '';
}
