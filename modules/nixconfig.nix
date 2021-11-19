{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    trustedUsers = [ "@wheel" ];
    autoOptimiseStore = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
