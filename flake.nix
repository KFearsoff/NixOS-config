{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
    #impermanence.url = "github:nix-community/impermanence";
    #impermanence.url = "path:/home/nixchad/Projects/impermanence";
    impermanence.url = "github:nix-community/impermanence/8ca70a91e461796e2232dc51a2f8ca1375f4a25a";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    zsh-you-should-use.url = "github:MichaelAquilina/zsh-you-should-use";
    zsh-you-should-use.flake = false;

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";
    deploy-rs.inputs.flake-compat.follows = "flake-compat";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
    pre-commit-hooks.inputs.flake-compat.follows = "flake-compat";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs = {
      flake-compat.follows = "flake-compat";
      pre-commit-hooks.follows = "pre-commit-hooks";
      nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    with import ./lib/builders.nix {
      inherit inputs;
      inherit (inputs.self) overlays;
      patches = [
        #overlays/0001-rollback-waybar-0.9.13.patch
        #{
        #  url = "https://github.com/NixOS/nixpkgs/pull/198638.patch";
        #  sha256 = "sha256-uL9fU8+0CnmR0fBCmz8GhNtmuJOmgo9j8rmFRTqM2iE=";
        #}
        #{
        #  url = "https://github.com/NixOS/nixpkgs/pull/205649.patch";
        #  sha256 = "sha256-VsPYdHvqEi+zq0q6d+MaskKj1fsKZE6h2apx92whUiU=";
        #}
      ];
    };
      rec {
        overlays =
          {
            nur = inputs.nur.overlay;
            neovim-nightly-overlay = inputs.neovim-nightly-overlay.overlay;
          }
          // (import ./overlays);

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
              ./suites/office.nix
              ./suites/graphics.nix
              ./suites/shell.nix
            ];
          };

          cloudberry = buildSystem {
            hostname = "cloudberry";
            extraModules = [
              ./hosts/cloudberry
              ./suites/common-services.nix
              ./suites/private-services.nix
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
            user = "root";
            sshUser = "nixchad";
            profiles.system.path = x86_64-linux.activate.nixos inputs.self.nixosConfigurations.blackberry;
          };

          cloudberry = {
            hostname = "cloudberry";
            user = "root";
            sshUser = "nixchad";
            profiles.system.path = x86_64-linux.activate.nixos inputs.self.nixosConfigurations.cloudberry;
          };
        };

        checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;

        packages.x86_64-linux =
          {
            iso = let
              image = buildSystem {hostname = "iso";};
            in
              image.config.system.build."isoImage";
          }
          // pkgs.lib.mapAttrs (_: v: v) (import ./pkgs {inherit pkgs;});

        apps.x86_64-linux.default = {
          type = "app";
          program = "${inputs.deploy-rs.defaultPackage.x86_64-linux}/bin/deploy";
        };
      }
      // inputs.flake-utils.lib.eachDefaultSystem (system: {
        formatter = pkgs.alejandra;

        devShells.default = inputs.devenv.lib.mkShell {
          inherit inputs pkgs;

          modules = [
            {
              packages = [
                pkgs.just
                inputs.deploy-rs.defaultPackage.${system}
              ];

              pre-commit.hooks = {
                # Variety
                shellcheck.enable = true;
                shfmt.enable = true;
                actionlint.enable = true;
                mdsh.enable = true;
                markdownlint.enable = true;
                commitizen.enable = true;

                # Nix
                alejandra.enable = true;
                deadnix.enable = true;
                statix.enable = true;

                cargo-check.enable = true;
                clippy.enable = true;
                rustfmt.enable = true;
              };
            }
          ];
        };
      });
}
