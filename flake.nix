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

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";
    deploy-rs.inputs.flake-compat.follows = "flake-compat";
  };

  outputs = inputs:
    with import ./lib/builders.nix {
      inherit inputs;
      overlays = inputs.self.overlays;
      patches = f:
        with f; [];
    };
      rec {
        overlays = {
          default = import ./overlays;
          nur = inputs.nur.overlay;
          neovim-nightly-overlay = inputs.neovim-nightly-overlay.overlay;
        };

        nixosConfigurations = {
          blackberry = buildSystem {
            hostname = "blackberry";
            extraModules = [
              ./hosts/blackberry
              ./suites/cli.nix
              ./suites/sway.nix
              ./suites/games.nix
              ./suites/gui.nix
              ./suites/work.nix
              ./suites/common-services.nix
              ./suites/private-services.nix
              ./suites/office.nix
              ./suites/graphics.nix
              ./suites/shell.nix
            ];
          };
        };

        allMachines = let
          toLink = name: value: {
            inherit name;
            path = value.config.system.build.toplevel;
          };
          links = pkgs.lib.mapAttrsToList toLink nixosConfigurations;
        in
          pkgs.linkFarm "all-machines" links;

        deploy.nodes = with inputs.deploy-rs.lib; {
          blackberry = {
            hostname = "blackberry";
            sshUser = "nixchad";
            profiles.system.path = x86_64-linux.activate.nixos inputs.self.nixosConfigurations.blackberry;
          };
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
      }
      // inputs.flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [inputs.devshell.overlay];
        };
      in {
        formatter = pkgs.alejandra;

        devShell = pkgs.devshell.mkShell {
          imports = [(pkgs.devshell.importTOML ./devshell.toml)];
        };
      });
}
