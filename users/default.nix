{
  imports = [
    ./nixchad.nix
  ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      verbose = true;
      sharedModules = [ ../homeManagerModules ];
    };
  };
}
