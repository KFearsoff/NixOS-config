{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "blackberry";
        system = "x86_64-linux";
        sshUser = "nixchad";
        sshKey = "/home/nixchad/.ssh/id_ed25519";
        maxJobs = 12;
        speedFactor = 100;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpGdVB4ZVFzQ0MyUGtSMjFNU3hna0FZREZxSjZzQVJYWkxaUkh1eTk5b3Egcm9vdEBibGFja2JlcnJ5Cg==%";
      }
    ];
    settings = {
      auto-optimise-store = true;
      trusted-users = ["@wheel"];
    };
    binaryCaches = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    # keep-outputs and keep-derivations options are great for development shells
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
      keep-outputs = true
      keep-derivations = true
      warn-dirty = false
      builders-use-substitutes = true
    '';
  };
}
