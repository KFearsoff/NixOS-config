{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    # keep-outputs and keep-derivations options are great for development shells
    extraOptions =
      ''
        experimental-features = nix-command flakes ca-derivations 
        keep-outputs = true
        keep-derivations = true
      '';
  };
}
