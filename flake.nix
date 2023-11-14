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
    firefox = {
      url = "github:colemickens/flake-firefox-nightly";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat-dep";
      };
    };
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

  outputs = inputs: let
    overlays =
      {
        neovim-nightly-overlay = inputs.neovim-nightly-overlay.overlay;
      }
      // (import ./overlays);
    hostSystem = "x86_64-linux";
    importedLib = import ./lib/builders.nix {
      inherit inputs overlays hostSystem;
      patches = f:
        with f; [
          #(pr <number> <sha>)
          (pr 266598 "1w5lrr01k787sj9wpn6wc1s5ih2cfy1p2d4fckfzyj7b1q5wiv4y")
        ];
    };
    inherit (importedLib) buildSystem pkgs;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-linux"];

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
              ./suites/shell.nix
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
              ./suites/shell.nix
            ];
          };
        };

        allMachines = let
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

        checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        devenv.shells.default = {
          packages = [
            pkgs.just
            inputs.deploy-rs.defaultPackage.${system}
            pkgs.nvd
          ];

          # https://github.com/cachix/devenv/issues/528
          containers = pkgs.lib.mkForce {};

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
            alejandra.enable = true;
            deadnix.enable = true;
            # statix.enable = true;
          };
        };

        apps.default = {
          type = "app";
          program = "${inputs.deploy-rs.defaultPackage.${system}}/bin/deploy";
        };

        packages =
          {
            iso = let
              image = buildSystem {hostname = "iso";};
            in
              image.config.system.build."isoImage";
          }
          // pkgs.lib.mapAttrs (_: v: v) (import ./pkgs {inherit pkgs;});
      };
    };
}
