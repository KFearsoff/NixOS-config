{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
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

    zsh-autosuggestions.url = "github:zsh-users/zsh-autosuggestions";
    zsh-autosuggestions.flake = false;
    zsh-you-should-use.url = "github:MichaelAquilina/zsh-you-should-use";
    zsh-you-should-use.flake = false;
    zsh-history-substring-search.url = "github:zsh-users/zsh-history-substring-search";
    zsh-history-substring-search.flake = false;
    zsh-nix-shell.url = "github:chisui/zsh-nix-shell";
    zsh-nix-shell.flake = false;
    nur.url = "github:nix-community/NUR";
    nix-colors.url = "github:misterio77/nix-colors";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs@{ self, nixpkgs, unstable, flake-utils, hardware, home-manager, neovim-nightly-overlay, nur, ... }:
    let
      buildSystem = system: pkgs: extraModules: pkgs.lib.nixosSystem {
        inherit system;
        specialArgs = with self.inputs; { inherit system inputs zsh-autosuggestions zsh-you-should-use zsh-history-substring-search zsh-nix-shell nix-colors; username = "nixchad"; };
        modules = [
          {
            nix = {
              extraOptions = ''
                flake-registry = /etc/nix/registry.json
              '';
              registry = {
                self.flake = inputs.self;
                nixpkgs = {
                  from = { id = "nixpkgs"; type = "indirect"; };
                  flake = pkgs;
                };
              };
            };
          }
        ] ++ extraModules;
      };
    in
    {
      overlays = [
        nur.overlay
        neovim-nightly-overlay.overlay
      ];
      nixosConfigurations = {
        blueberry = buildSystem "x86_64-linux" unstable
          [
            { nixpkgs.overlays = self.overlays; }
            ./hosts/blueberry
            ./users/nixchad.nix
            ./profiles/all.nix
          ];

        blackberry = buildSystem "x86_64-linux" unstable
          [
            { nixpkgs.overlays = self.overlays; }
            ./hosts/blackberry
            ./users/nixchad.nix
            ./modules/grub-efi.nix
            ./profiles/all.nix
          ];
      };
    };
}
