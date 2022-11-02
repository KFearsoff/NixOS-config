{
  imports = [
    ./cli.nix
    ./games.nix
    ./graphical.nix
    ./sway.nix
    ./common-services.nix
    ../modules/location.nix
  ];

  config = {
    nixchad.location.enable = true;
  };
}
