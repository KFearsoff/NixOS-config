{
  imports = [
    ./cli.nix
    ./games.nix
    ./graphical.nix
    ./sway.nix
    ./common-services.nix
    ../modules/location.nix
    ../modules/nixconf.nix
  ];

  config = {
    nixchad.location.enable = true;
  };
}
