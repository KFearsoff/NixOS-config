{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    hosts.url = "github:StevenBlack/hosts";
    hosts.inputs.nixpkgs.follows = "nixpkgs";
    hosts.inputs.flake-utils.follows = "flake-utils";
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
  }:
    with import ./lib/builders.nix {
      inherit inputs;
      overlays = self.overlays;
      patches = f:
        with f; [];
    };
      rec {
        overlays = {
          default = import ./overlays;
          nur = nur.overlay;
          neovim-nightly-overlay = neovim-nightly-overlay.overlay;
        };

        nixosConfigurations = {
          blueberry = buildSystem {
            hostname = "blueberry";
            extraModules = [
              ./hosts/blueberry
              ./suites
            ];
          };

          blackberry = buildSystem {
            hostname = "blackberry";
            extraModules = [
              ./hosts/blackberry
              ./suites
              ./suites/service-private.nix
            ];
          };

          virtberry = buildSystem {
            hostname = "virtberry";
            extraModules = [
              ./hosts/virtberry
              ./modules/location.nix
              {nixchad.location.enable = true;}
              ./suites/cli.nix
              ./suites/graphical.nix
              ./suites/service-common.nix
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
