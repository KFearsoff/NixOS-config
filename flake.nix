{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    secrets.flake = false;
    secrets.url = "path:/secrets";
  };

  outputs = inputs @ { self, nixpkgs, nixos-hardware, home-manager, nixpkgs-unstable, secrets, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        nixpkgs.config.allowUnfree = true;
        unstable = (import nixpkgs-unstable {
          inherit system;
          config = { allowUnfree = true; };
        });
      };
      buildConfig = modules: { inherit modules system specialArgs; };
      buildSystem = modules: lib.nixosSystem (buildConfig modules);
    in
      {
      nixosConfigurations = {
        nixos = buildSystem [
          ./configuration.nix
          ./hardware-configuration.nix
          ./home.nix
          "${secrets}/smb.nix"
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-pc
        ];  
      };
    };
}
