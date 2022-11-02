{
  imports = [
    ../profiles/gui
    ../profiles/newsboat.nix
    ../modules/graphical
    ../modules/pipewire.nix
  ];

  config = {
    nixchad.graphical.enable = true;
  };
}
