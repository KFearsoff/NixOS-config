{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";

    secrets.flake = false;
    secrets.url = "path:/secrets";
    
    neovim.url = "github:nix-community/neovim-nightly-overlay/master";

    zsh-autosuggestions.url = "github:zsh-users/zsh-autosuggestions";
    zsh-autosuggestions.flake = false;
    zsh-you-should-use.url = "github:MichaelAquilina/zsh-you-should-use";
    zsh-you-should-use.flake = false;
    zsh-history-substring-search.url = "github:zsh-users/zsh-history-substring-search";
    zsh-history-substring-search.flake = false;
    zsh-nix-shell.url = "github:chisui/zsh-nix-shell";
    zsh-nix-shell.flake = false;
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs@{ self, nixpkgs, unstable, flake-utils, nixos-hardware, home-manager, secrets, neovim, nur, ... }:
  let
    buildSystem = system: pkgs: extraModules: pkgs.lib.nixosSystem {
      inherit system;
      specialArgs = with self.inputs; { inherit system inputs zsh-autosuggestions zsh-you-should-use zsh-history-substring-search zsh-nix-shell; };
      modules = [ { nixpkgs.overlays = [ nur.overlay ]; }
      ] ++ extraModules;
    };
  in
    {
      nixosConfigurations = {
        nixos = buildSystem "x86_64-linux" unstable 
        [
          ./hosts/blueberry
          ./users/user.nix
          ./profiles/all.nix
          ./modules/grub-efi.nix
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc
          "${secrets}/smb.nix"
        ];

        blackberry = buildSystem "x86_64-linux" unstable 
        [
          ./hosts/blackberry
          ./users/nixchad.nix
          ./profiles/all.nix
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc
        ];
      };
    };
}
