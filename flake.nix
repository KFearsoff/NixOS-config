{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    secrets.flake = false;
    secrets.url = "path:/secrets";
    
    neovim.url = "github:nix-community/neovim-nightly-overlay/master";
  };

  outputs = inputs@{ self, nixpkgs, unstable, fup, nixos-hardware, home-manager, secrets, neovim, ... }:
#    let
#      # A function with 4 inputs: system architecture, nixpkgs to use, system config, extra modules
#      # Outputs a merged list of common modules and specified modules 
#      buildSystem = system: nixpkgs-ver: extraModules: nixpkgs-ver.lib.nixosSystem {
#        inherit system; 
#        specialArgs = { inherit system inputs; };
#        modules = ([
#          # System configuration for this host
##          builtins.elemAt (import host { pkgs = nixpkgs-ver; }).imports 0 
#          # Common configuration
#
#          # Home-Manager configuration
##          home-manager.nixosModules.home-manager {
##            home-manager.useGlobalPkgs = true;
##            home-manager.useUserPackages = true;
##            home-manager.users.user = builtins.toPath (host + "/home.nix") {
##              inherit inputs system;
##              pkgs = import nixpkgs-ver { inherit system; };
##              lib = nixpkgs-ver.lib;
##            };
##          }
#        ] ++ extraModules);
#      }; 
#    in
#      {
#        nixosConfigurations = {
#          nixos = buildSystem "x86_64-linux" inputs.nixpkgs-unstable 
#          [
#              ./hosts/blueberry
#              ./desktop 
#              nixos-hardware.nixosModules.common-pc-ssd
#              nixos-hardware.nixosModules.common-cpu-intel
#              nixos-hardware.nixosModules.common-pc
#              "${secrets}/smb.nix"  
#            ];
#        };
#      }; 


    let
      inherit (fup.lib) mkFlake exportOverlays exportPackages exportModules;
    in
      mkFlake {
        inherit self inputs;

        supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
        channelsConfig.allowUnfree = true;
        hostDefaults = {
          channelName = "unstable";
          system = "x86_64-linux";
          modules = [ ];
        };

        channels.nixpkgs.input = nixpkgs;
        channels.unstable.input = unstable;

#        overlay = import ./overlays;

        sharedOverlays = [
#          self.overlay
          neovim.overlay
        ];

        nixosModules = exportModules [
          ./hosts/blueberry
        ];

        hosts.nixos.modules = with self.nixosModules;
        [
          blueberry 
#            ./hosts/blueberry
            ./desktop
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc
            "${secrets}/smb.nix"
        ];
      };
}
