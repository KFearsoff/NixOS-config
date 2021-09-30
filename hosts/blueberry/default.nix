{ pkgs, ... }:
{
  imports = [
    ./configuration.nix
    ./home.nix
    ./hardware.nix
  ];
}
