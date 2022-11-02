{
  imports = [
    ../modules/location.nix
    ../modules/nixconf.nix
    ../modules/virtualisation.nix
    ../modules/common-services
    ../modules/games
    ../modules/graphical
    ../modules/pipewire.nix
    ../modules/private-services
  ];

  config = {
    nixchad.location.enable = true;
  };
}
