{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    #home-manager.inputs.nixpkgs.follows = "unstable";

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
  };

  outputs = inputs@{ self, nixpkgs, unstable, flake-utils, nixos-hardware, home-manager, secrets, neovim, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, ... }:
    let
      buildSystem = system: pkgs: extraModules: pkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit system inputs zsh-autosuggestions zsh-you-should-use zsh-history-substring-search zsh-nix-shell; };
        modules = ([
        ] ++ extraModules);
      };
      #makeHome = system: pkgs: user: path: {
      #  modules.home-manager.nixosModules.home-manager = {
      #    home-manager.useGlobalPkgs = true;
      #    home-manager.useUserPackages = true;
      #    home-manager.users.${user} = import path {
      #      inherit inputs system;
      #      lib = pkgs.lib;
      #      pkgs = import pkgs { inherit system; };
      #    };
      #  };
      #};
    in
      {
      #eachDefaultSystem = (system: {
        nixosConfigurations = {
          nixos = buildSystem "x86_64-linux" unstable 
          [
            ./hosts/blueberry
            ./desktop
            #(makeHome "x86_64-linux" unstable "user" ./hosts/blueberry/home.nix)
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc
            "${secrets}/smb.nix"
          ];
        };
      #});
      };
}
