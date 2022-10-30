{ lib, ... }:
let
  metadata = lib.importTOML ./metadata.toml;
  step-1 = builtins.attrNames metadata;
  step-2 = builtins.foldl' (x: y: x // metadata."${y}") {} step-1;
  step-3 = lib.filterAttrs (n: v: builtins.hasAttr "syncthing" v) step-2;
  step-4 = lib.mapAttrs (n: v: v.syncthing // { addresses = ["tcp://${n}" "quic://${n}"];}) step-3;
in {
  inherit metadata;
  syncthingDevicesConfig = step-4;
}
