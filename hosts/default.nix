{ pkgs, ... }:

{
  nix = {
    trustedUsers = [ "root" ];
    autoOptimiseStore = true;
