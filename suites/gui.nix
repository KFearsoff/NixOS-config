{
  imports = [
    ../profiles/gui
  ];

  config = {
    nixchad.gui.enable = true;
    nixchad.newsboat.enable = true;
    nixchad.fonts.enable = true;
    nixchad.alacritty.enable = true;
  };
}
