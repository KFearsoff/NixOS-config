{
  inputs,
  pkgs,
  ...
}:
{
  nix = {
    # pin all the nixpkgs to the version in the flake
    registry = {
      self.flake = inputs.self;
      nixpkgs.flake = inputs.nixpkgs;
    };

    package = pkgs.lix;

    settings = {
      trusted-users = [ "@wheel" ];
      auto-optimise-store = true;
      keep-going = true;
      keep-outputs = true;
      warn-dirty = false;
      log-lines = 9999;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
  };
}
