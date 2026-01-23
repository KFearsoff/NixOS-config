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
    treefmt-nix-dep = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS utils
    hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

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
    nixocaine = {
      url = "https://git.madhouse-project.org/iocaine/nixocaine/archive/stable.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
        systems.follows = "systems-dep";
        treefmt-nix.follows = "treefmt-nix-dep";
      };
    };
    ai-robots-txt = {
      url = "github:ai-robots-txt/ai.robots.txt";
      flake = false;
    };

    # User utils
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
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
      # FIXME: file a bug to Algernon that overlay should be done unconditionally
      overlays = (import ./overlays) // {
        iocaine = inputs.nixocaine.overlays.default;
      };
      hostSystem = "x86_64-linux";
      importedLib = import ./lib/builders.nix {
        inherit inputs overlays hostSystem;
        patches =
          fetchers: with fetchers; {
            nixpkgs = [
              # (npr 305569 "0n0nbriaxfcbalyqp59d3qg91vni1p56avv19wlqhgghy74wr5f1")
              # (npr 436857 "sha256-3BOcRKoZeF2kVZig/A4cf8ZYn3GFQyKt2Pxaoc+dDvY=")
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

      formatter.${hostSystem} = pkgs.nixfmt;

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
          default_stages = [
            "pre-commit"
            "pre-push"
          ];
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
            # commitizen.enable = true;
            editorconfig-checker.enable = true;

            # Nix
            nixfmt.enable = true;
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
