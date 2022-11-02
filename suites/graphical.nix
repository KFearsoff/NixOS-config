{
  imports = [
    ../profiles/gui
    ../profiles/newsboat.nix
  ];

  config = {
    nixchad.graphical.enable = true;
  };
}
