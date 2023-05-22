{
  description = "NixOS configuration with flakes";

  inputs = {
    # Pkg sources
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    # Libraries
    systems-dep.url = "github:nix-systems/default";
    flake-utils-dep = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems-dep";
    };
    flake-compat-dep = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";

    # NixOS utils
    hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #impermanence.url = "github:nix-community/impermanence";
    #impermanence.url = "path:/home/nixchad/Projects/impermanence";
    impermanence.url = "github:nix-community/impermanence/8ca70a91e461796e2232dc51a2f8ca1375f4a25a";

    # Services
    tailforward = {
      url = "github:KFearsoff/tailforward";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-dep";
        devenv.follows = "devenv";
      };
    };

    # User utils
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";

    # User aplications
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat-dep";
        neovim-flake.follows = "neovim-flake-dep";
        flake-parts.follows = "flake-parts";
      };
    };
    neovim-flake-dep = {
      url = "github:neovim/neovim?dir=contrib";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils-dep";
      };
    };
    zsh-you-should-use = {
      url = "github:MichaelAquilina/zsh-you-should-use";
      flake = false;
    };

    # Development
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        flake-compat.follows = "flake-compat-dep";
        pre-commit-hooks.follows = "pre-commit-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # CI
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-utils.follows = "flake-utils-dep";
        flake-compat.follows = "flake-compat-dep";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # CD
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils-dep";
        flake-compat.follows = "flake-compat-dep";
      };
    };
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
      // inputs.flake-utils-dep.lib.eachDefaultSystem (system: {
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
                # Shell
                shellcheck.enable = true;
                shfmt.enable = true;

                # Markdown
                mdsh.enable = true;
                markdownlint.enable = true;

                # Variety
                actionlint.enable = true;
                commitizen.enable = true;

                # Nix
                alejandra.enable = true;
                deadnix.enable = true;
                statix.enable = true;
              };
            }
          ];
        };
      });
}
