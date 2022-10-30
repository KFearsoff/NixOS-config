{ lib, ... }:
with lib;
let
  metadata = importTOML ./metadata.toml;
  metadataTypes = builtins.attrNames metadata;
  metadataNoTypes = builtins.foldl' (x: y: x // metadata."${y}") {} metadataTypes;
  syncthingEntries = filterAttrs (n: v: builtins.hasAttr "syncthing" v) metadataNoTypes;
in {
  inherit metadata;
  syncthingDevicesConfig = mapAttrs (n: v: v.syncthing // { addresses = ["tcp://${n}" "quic://${n}"];}) syncthingEntries;
  syncthingHostsList = builtins.attrNames (filterAttrs (n: v: builtins.hasAttr "syncthing" v) metadata.hosts);
  syncthingAllList = builtins.attrNames syncthingEntries;
}
