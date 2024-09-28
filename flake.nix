{
  description = "NixOS configuration with flakes";

  inputs = {
    # Pkg sources
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    # Lix
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # pre-commit-hooks.follows = "pre-commit-hooks";
        # flake-compat.follows = "flake-compat-dep";
      };
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        lix.follows = "lix";
        # flake-utils.follows = "flake-utils-dep";
      };
    };

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
    impermanence.url = "github:nix-community/impermanence";

    # Services
    tailforward = {
      url = "github:KFearsoff/tailforward";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems-dep";
        devenv.follows = "devenv";
        flake-parts.follows = "flake-parts";
      };
    };
    website = {
      url = "github:KFearsoff/website";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devenv.follows = "devenv";
      };
    };

    # User utils
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        flake-compat.follows = "flake-compat-dep";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # User aplications
    arkenfox = {
      url = "github:arkenfox/user.js";
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

    nu-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      overlays = import ./overlays;
      hostSystem = "x86_64-linux";
      importedLib = import ./lib/builders.nix {
        inherit inputs overlays hostSystem;
        patches =
          fetchers: with fetchers; {
            nixpkgs = [
              # (npr 305569 "0n0nbriaxfcbalyqp59d3qg91vni1p56avv19wlqhgghy74wr5f1")
              # Steam chop
              (npr 341219 "0z104cbl4g55czs2b4f05ynz8xhh0drdvm8pl6kngwb6zkzcy76k")
            ];
            #(pr <number> <sha>)
          };
      };
      inherit (importedLib) buildSystem pkgs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        nixosConfigurations = {
          blackberry = buildSystem {
            hostname = "blackberry";
            extraModules = [
              ./suites/cli.nix
              ./suites/sway.nix
              ./suites/games.nix
              ./suites/gui.nix
              ./suites/work.nix
              ./suites/common-services.nix
              #./suites/office.nix
              #./suites/graphics.nix
            ];
          };

          cloudberry = buildSystem {
            hostname = "cloudberry";
            extraModules = [
              ./suites/common-services.nix
              ./suites/private-services.nix
            ];
          };

          blueberry = buildSystem {
            hostname = "blueberry";
            extraModules = [
              ./suites/cli.nix
              ./suites/sway.nix
              ./suites/games.nix
              ./suites/gui.nix
              ./suites/work.nix
              ./suites/common-services.nix
              #./suites/office.nix
              #./suites/graphics.nix
            ];
          };
        };

        allMachines =
          let
            toLink = name: value: {
              inherit name;
              path = value.config.system.build.toplevel;
            };
            links = pkgs.lib.mapAttrsToList toLink inputs.self.nixosConfigurations;
          in
          pkgs.linkFarm "all-machines" links;

        deploy.nodes = with inputs.deploy-rs.lib; {
          blackberry = {
            hostname = "blackberry";
            user = "root";
            sshUser = "nixchad";
            profiles.system.path = x86_64-linux.activate.nixos inputs.self.nixosConfigurations.blackberry;
            fastConnection = true;
          };

          cloudberry = {
            hostname = "cloudberry";
            user = "root";
            sshUser = "nixchad";
            profiles.system.path = x86_64-linux.activate.nixos inputs.self.nixosConfigurations.cloudberry;
            fastConnection = true;
          };

          blueberry = {
            hostname = "blueberry";
            user = "root";
            sshUser = "nixchad";
            profiles.system.path = x86_64-linux.activate.nixos inputs.self.nixosConfigurations.blueberry;
            fastConnection = true;
          };
        };

        checks = builtins.mapAttrs (
          _: deployLib: deployLib.deployChecks inputs.self.deploy
        ) inputs.deploy-rs.lib;
      };

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          formatter = pkgs.nixfmt-rfc-style;

          devenv.shells.default = {
            packages = [
              pkgs.just
              inputs.deploy-rs.defaultPackage.${system}
              pkgs.nvd
              pkgs.nixfmt-rfc-style
              pkgs.nix-output-monitor
            ];

            languages = {
              nix.enable = true;
              lua.enable = true;
            };

            # https://github.com/cachix/devenv/issues/528
            containers = pkgs.lib.mkForce { };

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
              editorconfig-checker.enable = true;

              # Nix
              nixfmt-rfc-style.enable = true;
              deadnix.enable = true;
              statix.enable = true;
            };
          };

          apps.default = {
            type = "app";
            program = "${inputs.deploy-rs.defaultPackage.${system}}/bin/deploy";
          };

          packages = {
            iso =
              let
                image = buildSystem { hostname = "iso"; };
              in
              image.config.system.build."isoImage";
          } // pkgs.lib.mapAttrs (_: v: v) (import ./pkgs { inherit pkgs; });
        };
    };
}
