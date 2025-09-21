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
        "pipe-operator"
      ];

      builders-use-substitutes = true;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      randomizedDelaySec = "1h";
    };
  };
}
