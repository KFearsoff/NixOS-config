{
  inputs,
  overlays ? { },
  patches ? _: { },
  hostSystem ? "x86_64-linux",
  targetSystems ? [
    "x86_64-linux"
    "aarch64-linux"
  ],
  config ? { },
}:
let
  patchFetchers = rec {
    pr =
      repo: id: hash:
      builtins.fetchurl {
        url = "https://github.com/${repo}/pull/${builtins.toString id}.diff";
        sha256 = hash;
      };
    npr = pr "NixOS/nixpkgs";
    hmpr = pr "nix-community/home-manager";
  };

  pkgsForPatching = import inputs.nixpkgs { system = hostSystem; };

  fetchedPatches = patches patchFetchers;

  patchInput =
    name: value:
    if (fetchedPatches.${name} or [ ]) != [ ] then
      let
        patchedSrc = pkgsForPatching.applyPatches {
          name = "source";
          src = value;
          patches = fetchedPatches.${name};
        };
      in
      patchedSrc
    else
      value;

  patchedInputs = builtins.mapAttrs patchInput inputs;

  patchedNixpkgs = import patchedInputs.nixpkgs;

  patchedNixpkgsBySystem = pkgsForPatching.lib.attrsets.genAttrs targetSystems (
    system:
    patchedNixpkgs {
      inherit system;
      config = config // {
        allowUnfree = true;
      };
      overlays = builtins.attrValues overlays;
    }
  );
  patchedNixpkgsHost = patchedNixpkgsBySystem.${hostSystem};

  buildSystem =
    {
      hostname,
      extraModules ? [ ],
      system ? "x86_64-linux",
      username ? "nixchad",
    }:
    let
      machineSpecificConfig = ../hosts + "/${hostname}";
      machineSpecificModules =
        if builtins.pathExists machineSpecificConfig then [ machineSpecificConfig ] else [ ];
      pkgs = patchedNixpkgsBySystem.${system};
    in
    import "${patchedInputs.nixpkgs}/nixos/lib/eval-config.nix" {
      inherit system;

      modules =
        [
          {
            networking.hostName = hostname;
            nixpkgs.pkgs = pkgs;
          }
          inputs.home-manager.nixosModules.home-manager
          inputs.impermanence.nixosModules.impermanence
          inputs.stylix.nixosModules.stylix
          inputs.nur.modules.nixos.default
          inputs.lix-module.nixosModules.default
          ../users
          ../nixosModules
          ./metadata.nix
        ]
        ++ machineSpecificModules
        ++ extraModules;

      specialArgs = {
        inputs = patchedInputs;
        rawInputs = inputs;
        pkgsHost = patchedNixpkgsHost;
        inherit username;
        servername = "cloudberry";
      };
    };
in
{
  inherit buildSystem;
  pkgs = patchedNixpkgsHost;
}
