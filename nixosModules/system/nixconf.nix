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
      substituters = [
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
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
