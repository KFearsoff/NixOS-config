{
  imports = [
    ./cli.nix
    ./games.nix
    ./graphical.nix
    ./sway.nix
    ./service-common.nix
    ../modules/location.nix
  ];

  config = {
    nixchad.location.enable = true;
  };
}
