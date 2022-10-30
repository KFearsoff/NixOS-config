{ lib, ... }:
with lib;
let
  metadata = importTOML ./metadata.toml;
  step-1 = builtins.attrNames metadata;
  step-2 = builtins.foldl' (x: y: x // metadata."${y}") {} step-1;
  step-3 = filterAttrs (n: v: builtins.hasAttr "syncthing" v) step-2;
  step-4 = mapAttrs (n: v: v.syncthing // { addresses = ["tcp://${n}" "quic://${n}"];}) step-3;
in {
  inherit metadata;
  syncthingDevicesConfig = step-4;
  syncthingHostsList = builtins.attrNames (filterAttrs (n: v: builtins.hasAttr "syncthing" v) metadata.hosts);
}
