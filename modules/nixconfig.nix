{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    trustedUsers = [ "@wheel" ];
    autoOptimiseStore = true;
    package = pkgs.nixUnstable;
    # keep-outputs and keep-derivations options are great for development shells
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations 
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
