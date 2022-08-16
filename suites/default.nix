{
  imports = [
    ./cli.nix
    ./games.nix
    ./graphical.nix
    ./sway.nix
    ../modules/location.nix
  ];

  config = {
    nixchad.location.enable = true;
  };
}
