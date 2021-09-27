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
    
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, nixos-hardware, home-manager, secrets, ... }:
    let
      # A function with 4 inputs: system architecture, nixpkgs to use, system config, extra modules
      # Outputs a merged list of common modules and specified modules 
      buildSystem = system: nixpkgs-ver: configurationNix: extraModules: nixpkgs-ver.lib.nixosSystem {
        inherit system; 
        specialArgs = { inherit system inputs; };
        modules = ([
          # System configuration for this host
          configurationNix

          # Common configuration

          # Home-Manager configuration
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.user = import ./home.nix {
              inherit inputs system;
              pkgs = import nixpkgs-ver { inherit system; };
              lib = nixpkgs-ver.lib;
            };
          }
        ] ++ extraModules );
      }; 
    in
      {
        nixosConfigurations = {
          nixos = buildSystem "x86_64-linux" inputs.nixpkgs-unstable 
            ./hosts/blueberry.nix
            [
              ./desktop 
              ./desktop/fonts.nix
              ./desktop/autolock.nix
              ./desktop/swap-caps-esc.nix
              nixos-hardware.nixosModules.common-pc-ssd
              nixos-hardware.nixosModules.common-cpu-intel
              nixos-hardware.nixosModules.common-pc
              "${secrets}/smb.nix"  
            ];
        };
      }; 
}
