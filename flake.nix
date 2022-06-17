{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";
    home-manager.inputs.flake-compat.follows = "flake-compat";

    home-manager-newsboat.url = "github:nix-community/home-manager/fb82568aa899f947a26d4d0c01cb30960f53f182";
    home-manager-newsboat.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.inputs.flake-compat.follows = "flake-compat";
    neovim-nightly-overlay.inputs.neovim-flake.follows = "neovim-flake";

    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
    neovim-flake.inputs.flake-utils.follows = "flake-utils";

    nur.url = "github:nix-community/NUR";
    nix-colors.url = "github:misterio77/nix-colors";
    impermanence.url = "github:nix-community/impermanence";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    zsh-you-should-use.url = "github:MichaelAquilina/zsh-you-should-use";
    zsh-you-should-use.flake = false;
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    hardware,
    home-manager,
    neovim-nightly-overlay,
    nur,
    nix-colors,
    impermanence,
    devshell,
    sops-nix,
    ...
  }: let
    buildSystem = {
      system ? "x86_64-linux",
      pkgs ? nixpkgs,
      username ? "nixchad",
      extraModules,
    }:
      pkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs nix-colors username;};
        modules =
          [
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
            (./users + "/${username}.nix")
          ]
          ++ extraModules;
      };
  in
    {
      overlays = {
        default = import ./overlays;
        nur = nur.overlay;
        neovim-nightly-overlay = neovim-nightly-overlay.overlay;
      };
      nixosConfigurations = {
        blueberry = buildSystem {
          extraModules = [
            {nixpkgs.overlays = builtins.attrValues self.overlays;}
            ./hosts/blueberry
            ./suites
          ];
        };

        blackberry = buildSystem {
          extraModules = [
            {nixpkgs.overlays = builtins.attrValues self.overlays;}
            ./hosts/blackberry
            ./suites
          ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.alejandra;

      devShell = let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [devshell.overlay];
        };
      in
        pkgs.devshell.mkShell {
          imports = [(pkgs.devshell.importTOML ./devshell.toml)];
        };
    });
}
