{
  inputs,
  overlays,
  patches ? f: [],
}: let
  patchFetchers = {
    pr = id: builtins.fetchurl "https://github.com/NixOS/nixpkgs/pull/${builtins.toString id}.patch";
  };
  pkgsForPatching = import inputs.nixpkgs {system = builtins.currentSystem;};
  patchesToApply = patches patchFetchers;
  patchedNixpkgsDrv =
    if patchesToApply != []
    then
      pkgsForPatching.applyPatches {
        name = "nixpkgs-patched";
        src = inputs.nixpkgs;
        patches = patchesToApply;
      }
    else inputs.nixpkgs;
  patchedNixpkgs = import patchedNixpkgsDrv;
  patchedNixpkgsFor = system:
    patchedNixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  buildSystem = {
    hostname,
    extraModules ? [],
    system ? "x86_64-linux",
    username ? "nixchad",
  }: let
    machineSpecificConfig = ../hosts + "/${hostname}";
    machineSpecificModules =
      if builtins.pathExists machineSpecificConfig
      then [machineSpecificConfig]
      else [];
    pkgs = patchedNixpkgsFor system;
  in
    import "${patchedNixpkgsDrv}/nixos/lib/eval-config.nix" {
      inherit system;
      modules =
        [
          {
            networking.hostName = hostname;
            nixpkgs.pkgs = pkgs;
            nixpkgs.overlays = builtins.attrValues overlays;

            # pin all the nixpkgs to the version in the flake
            nix = {
              registry.nixpkgs.flake = patchedNixpkgsDrv;
              nixPath = ["nixpkgs=${patchedNixpkgsDrv}"];
            };
          }
          inputs.home-manager.nixosModules.home-manager
          inputs.impermanence.nixosModules.impermanence
          inputs.sops-nix.nixosModules.sops
          (../users + "/${username}.nix")
        ]
        ++ machineSpecificModules
        ++ extraModules;
      specialArgs = {
        inherit inputs username;
        nix-colors = inputs.nix-colors;
        servername = "blackberry";
      };
    };
in {
  inherit buildSystem;
  pkgs = patchedNixpkgsFor builtins.currentSystem;
}
