{
  inputs,
  overlays ? {},
  patches ? _: [],
  hostSystem ? "x86_64-linux",
  targetSystems ? ["x86_64-linux" "aarch64-linux"],
}: let
  patchFetchers = {
    pr = id: hash:
      builtins.fetchurl {
        url = "https://github.com/NixOS/nixpkgs/pull/${builtins.toString id}.diff";
        sha256 = hash;
      };
  };
  pkgsForPatching = import inputs.nixpkgs {system = hostSystem;};
  patchesToApply = patches patchFetchers;
  patchedNixpkgsDrv =
    if patchesToApply != []
    then
      pkgsForPatching.applyPatches
      {
        name = "nixpkgs-patched";
        src = inputs.nixpkgs;
        patches = patchesToApply;
      }
    else inputs.nixpkgs;
  patchedNixpkgs = import patchedNixpkgsDrv;
  patchedNixpkgsBySystem = pkgsForPatching.lib.attrsets.genAttrs targetSystems (system:
    patchedNixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = builtins.attrValues overlays;
    });
  patchedNixpkgsHost = patchedNixpkgsBySystem.${hostSystem};
  patchedInputs =
    inputs
    // {
      nixpkgs = patchedNixpkgsDrv;
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
    pkgs = patchedNixpkgsBySystem.${system};
  in
    import "${patchedNixpkgsDrv}/nixos/lib/eval-config.nix" {
      inherit system;
      modules =
        [
          {
            networking.hostName = hostname;
            nixpkgs.pkgs = pkgs;

            # pin all the nixpkgs to the version in the flake
            nix = {
              registry.nixpkgs.flake = patchedNixpkgsDrv;
              nixPath = ["nixpkgs=${patchedNixpkgsDrv}"];
            };
          }
          inputs.home-manager.nixosModules.home-manager
          inputs.impermanence.nixosModules.impermanence
          inputs.nur.nixosModules.nur
          (../users + "/${username}.nix")
          ../modules
          ./metadata.nix
        ]
        ++ machineSpecificModules
        ++ extraModules;
      specialArgs = {
        inputs = patchedInputs;
        inherit username;
        inherit (patchedInputs) nix-colors;
        metadata-path = ../hosts/metadata.toml;
        servername = "cloudberry";
      };
    };
in {
  inherit buildSystem;
  pkgs = patchedNixpkgsHost;
}
