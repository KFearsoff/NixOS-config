{
  inputs,
  overlays,
  system ? "x86_64-linux",
  patches ? [],
}: let
  pkgsForPatching = import inputs.nixpkgs {inherit system;};
  patchedNixpkgsDrv =
    if patches != []
    then
      pkgsForPatching.applyPatches {
        name = "nixpkgs-patched";
        src = inputs.nixpkgs;
        patches = builtins.map (x:
          if builtins.isPath x
          then x
          else pkgsForPatching.pkgs.fetchpatch x)
        patches;
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
          (../users + "/${username}.nix")
          ../modules
          ./metadata.nix
        ]
        ++ machineSpecificModules
        ++ extraModules;
      specialArgs = {
        inherit inputs username;
        inherit (inputs) nix-colors;
        metadata-path = ../hosts/metadata.toml;
        servername = "blackberry";
      };
    };
in {
  inherit buildSystem;
  pkgs = patchedNixpkgsFor system;
}
