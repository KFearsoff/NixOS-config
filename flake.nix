{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nushell-066.url = "github:nixos/nixpkgs/a778cafada011ad62229d1987eb085d732fd6110";
    flake-utils.url = "github:numtide/flake-utils";
    hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";

    home-manager-newsboat.url = "github:nix-community/home-manager/743f3ba9ace05886c9de06a65f5ea7ed4b2df09c";
    home-manager-newsboat.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-newsboat.inputs.utils.follows = "flake-utils";

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
    #impermanence.url = "path:/home/nixchad/Projects/impermanence";

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
        specialArgs = {
          inherit inputs nix-colors username;
          servername = "blackberry";
        };
        modules =
          [
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
            (./users + "/${username}.nix")
            {nixpkgs.overlays = builtins.attrValues self.overlays;}
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
            ./hosts/blueberry
            ./suites
          ];
        };

        blackberry = buildSystem {
          extraModules = [
            ./hosts/blackberry
            ./suites
            ./suites/service-private.nix
          ];
        };

        virtberry = buildSystem {
          extraModules = [
            {nixpkgs.overlays = builtins.attrValues self.overlays;}
            ./hosts/virtberry
            ./suites/cli.nix
            ./suites/graphical.nix
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
