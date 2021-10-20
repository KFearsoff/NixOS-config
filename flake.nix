{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    #home-manager.inputs.nixpkgs.follows = "unstable";

    secrets.flake = false;
    secrets.url = "path:/secrets";
    
    neovim.url = "github:nix-community/neovim-nightly-overlay/master";
  };

  outputs = inputs@{ self, nixpkgs, unstable, flake-utils, nixos-hardware, home-manager, secrets, neovim, ... }:
    let
      buildSystem = system: pkgs: extraModules: pkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit system inputs; };
        modules = ([
        ] ++ extraModules);
      };
      #makeHome = system: pkgs: user: path: {
      #  modules.home-manager.nixosModules.home-manager = {
      #    home-manager.useGlobalPkgs = true;
      #    home-manager.useUserPackages = true;
      #    home-manager.users.${user} = import path {
      #      inherit inputs system;
      #      lib = pkgs.lib;
      #      pkgs = import pkgs { inherit system; };
      #    };
      #  };
      #};
    in
      {
      #eachDefaultSystem = (system: {
        nixosConfigurations = {
          nixos = buildSystem "x86_64-linux" unstable 
          [
            ./hosts/blueberry
            ./desktop
            #(makeHome "x86_64-linux" unstable "user" ./hosts/blueberry/home.nix)
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc
            "${secrets}/smb.nix"
          ];
        };
      #});
      };
}
