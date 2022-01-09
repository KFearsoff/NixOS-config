{ pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    trustedUsers = [ "@wheel" ];
    package = pkgs.nixUnstable;
    # keep-outputs and keep-derivations options are great for development shells
    # also empty the registry: it will allow you to not redownload 100MBs every time
    # you collect garbage, but those 100MBs will be stored on the disk
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-registry.html
    extraOptions =
      ''
        experimental-features = nix-command flakes ca-derivations 
        keep-outputs = true
        keep-derivations = true
      '';
    #let empty_registry = builtins.toFile "empty-flake-registry.json" ''{"flakes":[],"version":2}''; in
    #flake-registry = "${empty_registry}
    #registry.nixpkgs.flake = inputs.nixpkgs;
    #nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
