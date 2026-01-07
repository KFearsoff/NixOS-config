{
  inputs,
  overlays ? { },
  patches ? _: { },
  hostSystem ? "x86_64-linux",
}:
let
  patchFetchers = rec {
    pr =
      repo: id: hash:
      builtins.fetchurl {
        url = "https://github.com/${repo}/pull/${builtins.toString id}.diff?full_index=1";
        sha256 = hash;
      };
    npr = pr "NixOS/nixpkgs";
    hmpr = pr "nix-community/home-manager";
  };

  pkgsForPatching = import inputs.nixpkgs { system = hostSystem; };

  fetchedPatches = patches patchFetchers;

  patchInput =
    name: value:
    if fetchedPatches.${name} or [ ] != [ ] then
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
  patchedNixpkgsHost = patchedNixpkgs {
    system = hostSystem;
    config = {
      allowUnfree = true;
      # allowAliases = false; # Unsupported by colmena
    };
    overlays = builtins.attrValues overlays;
    inherit specialArgs;
  };

  specialArgs = {
    inputs = patchedInputs;
    rawInputs = inputs;
    username = "nixchad";
    servername = "cloudberry";
  };

  buildSystem =
    {
      hostname,
      extraModules ? [ ],
      system ? "x86_64-linux",
      allowLocalDeployment ? false,
      targetUser ? "nixchad",
    }:
    let
      machineSpecificConfig = ../hosts + "/${hostname}";
      machineSpecificModules =
        if builtins.pathExists machineSpecificConfig then [ machineSpecificConfig ] else [ ];
    in
    {
      imports = [
        {
          networking.hostName = hostname;
          nixpkgs = {
            config = {
              allowAliases = false;
              allowUnfree = true;
            };
            overlays = builtins.attrValues overlays;
            hostPlatform = system;
          };

          deployment = {
            inherit allowLocalDeployment targetUser;
            targetHost = hostname;
          };
        }
        inputs.home-manager.nixosModules.home-manager
        inputs.impermanence.nixosModules.impermanence
        inputs.stylix.nixosModules.stylix
        inputs.nur.modules.nixos.default
        inputs.lix-module.nixosModules.default
        inputs.nixocaine.nixosModules.default
        ../users
        ../nixosModules
        ./metadata.nix
      ]
      ++ machineSpecificModules
      ++ extraModules;
    };

  hiveMeta = {
    nixpkgs = patchedNixpkgsHost;
    inherit specialArgs;
  };
in
{
  inherit buildSystem hiveMeta;
  pkgs = patchedNixpkgsHost;
}
