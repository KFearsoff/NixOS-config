{
  description = "NixOS configuration with flakes";

  inputs = {
    # Pkg sources
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.flake-parts.follows = "flake-parts-dep";
    };

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
    flake-parts-dep = {
      url = "github:hercules-ci/flake-parts";
    };

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
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    website = {
      url = "github:KFearsoff/website";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };

    # User utils
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      # Pin to 1 commit older bcs HEAD broke rofi
      url = "github:nix-community/stylix/c700d41bb8ee32baed490c8128c1077b2b27183b";
      inputs = {
        flake-compat.follows = "flake-compat-dep";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        flake-parts.follows = "flake-parts-dep";
      };
    };

    # User aplications
    arkenfox = {
      url = "github:arkenfox/user.js";
      flake = false;
    };

    # CI
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat-dep";
        nixpkgs.follows = "nixpkgs";
      };
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # stable.follows = "nixpkgs";
        # nix-github-actions.follows = "nix-github-actions";
        flake-compat.follows = "flake-compat-dep";
        flake-utils.follows = "flake-utils-dep";
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
              # https://github.com/NixOS/nixpkgs/pull/428161#issuecomment-3145895543
              ./overlays/neotest.patch
              # (npr 436857 "sha256-3BOcRKoZeF2kVZig/A4cf8ZYn3GFQyKt2Pxaoc+dDvY=")
              (npr 437667 "sha256-iclyZj5VYhhYz3RWLcKXHfyp747EzmyAAkbOWST5kbg=")
            ];
            #(pr <number> <sha>)
          };
      };
      inherit (importedLib) buildSystem hiveMeta pkgs;
    in
    {
      nixosConfigurations = inputs.self.colmenaHive.nodes;

      colmenaHive = inputs.colmena.lib.makeHive {
        meta = hiveMeta;

        blackberry = buildSystem {
          allowLocalDeployment = true;
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
          allowLocalDeployment = true;
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

      formatter.${hostSystem} = pkgs.nixfmt-rfc-style;

      devShells.${hostSystem}.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.just
          (inputs.colmena.packages.${hostSystem}.colmena.override {
            inherit (inputs.lix.packages.${hostSystem}) nix-eval-jobs;
          })
          pkgs.nvd
          pkgs.nixfmt
          pkgs.nix-output-monitor

          pkgs.lua
          pkgs.lua-language-server
        ];

        inherit (inputs.self.checks.${hostSystem}.pre-commit-check) shellHook;
      };

      checks.${hostSystem} = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${hostSystem}.run {
          src = ./.;
          hooks = {
            # Shell
            shellcheck.enable = true;
            shellcheck.excludes = [ "\\.envrc" ];
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
            statix.package = pkgs.statix;
          };
        };
      };

      packages.${hostSystem} = {
        iso =
          let
            image = buildSystem { hostname = "iso"; };
          in
          image.config.system.build."isoImage";
      }
      // pkgs.lib.mapAttrs (_: v: v) (import ./pkgs { inherit pkgs; });
    };
}
