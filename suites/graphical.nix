{
  imports = [
    ../profiles/gui
    ../profiles/newsboat.nix
    ../modules/graphical
  ];

  config = {
    nixchad.graphical.enable = true;
  };
}
