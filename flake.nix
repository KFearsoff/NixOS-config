{
  description = "NixOS configuration with flakes";

  inputs = {
    # unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    unstable.url = "github:nixos/nixpkgs/b7493e35504d5f5ec5fa73db0ebfc1e731741016";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/a2ba21275e154a4877522cb408a620850cf39395";
    home-manager.inputs.nixpkgs.follows = "unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "unstable";
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    neovim-flake.inputs.nixpkgs.follows = "unstable";
    neovim-flake.inputs.flake-utils.follows = "flake-utils";
    neovim-nightly-overlay.inputs.flake-compat.follows = "flake-compat";
    neovim-nightly-overlay.inputs.neovim-flake.follows = "neovim-flake";

    neovim-lsp.url = "github:neovim/nvim-lspconfig";
    neovim-lsp.inputs.nixpkgs.follows = "unstable";
    neovim-lsp.inputs.flake-utils.follows = "flake-utils";

    zsh-you-should-use.url = "github:MichaelAquilina/zsh-you-should-use";
    zsh-you-should-use.flake = false;
    nur.url = "github:nix-community/NUR";
    nix-colors.url = "github:misterio77/nix-colors";
    impermanence.url = "github:nix-community/impermanence";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "unstable";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    unstable,
    flake-utils,
    hardware,
    home-manager,
    neovim-nightly-overlay,
    nur,
    nix-colors,
    pre-commit-hooks,
    impermanence,
    sops-nix,
    ...
  }: let
    buildSystem = system: pkgs: extraModules:
      pkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs nix-colors;
          username = "nixchad";
        };
        modules =
          [
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
            {
              nix = {
                extraOptions = ''
                  flake-registry = /etc/nix/registry.json
                '';
                registry = {
                  self.flake = inputs.self;
                  nixpkgs = {
                    from = {
                      id = "nixpkgs";
                      type = "indirect";
                    };
                    flake = pkgs;
                  };
                };
              };
            }
          ]
          ++ extraModules;
      };
  in
    {
      overlays = {
        nur = nur.overlay;
        neovim-nightly-overlay = neovim-nightly-overlay.overlay;
      };
      nixosConfigurations = {
        blueberry =
          buildSystem "x86_64-linux" unstable
          [
            {nixpkgs.overlays = builtins.attrValues self.overlays;}
            ./hosts/blueberry
            ./users/nixchad.nix
            ./suites
          ];

        blackberry =
          buildSystem "x86_64-linux" unstable
          [
            {nixpkgs.overlays = builtins.attrValues self.overlays;}
            ./hosts/blackberry
            ./users/nixchad.nix
            ./suites
          ];
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = unstable.legacyPackages.${system}.alejandra;

      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            statix.enable = true;
            alejandra.enable = true;
          };
        };
      };

      devShell = unstable.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;

        buildInputs = with unstable.legacyPackages.${system}.pkgs; [
          # sops
        ];
      };
    });
}
