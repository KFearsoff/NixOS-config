{lib, ...}:
with lib; let
  metadata = importTOML ../hosts/metadata.toml;
  metadataTypes = builtins.attrNames metadata;
  metadataNoTypes = builtins.foldl' (x: y: x // metadata."${y}") {} metadataTypes;
  syncthingEntries = filterAttrs (n: v: builtins.hasAttr "syncthing" v) metadataNoTypes;
  sshPubkeyEntries = filterAttrs (n: v: builtins.hasAttr "ssh-pubkey" v) metadataNoTypes;
  ipv4Entries = filterAttrs (n: v: builtins.hasAttr "ipv4" v) metadataNoTypes;
  ipv4HostsList = mapAttrsToList (n: v: "${v.ipv4} ${n}") ipv4Entries;
in {
  lib.metadata = {
    inherit metadata;
    syncthingDevicesConfig = mapAttrs (n: v: v.syncthing // {addresses = ["tcp://${n}" "quic://${n}"];}) syncthingEntries;
    syncthingHostsList = builtins.attrNames (filterAttrs (n: v: builtins.hasAttr "syncthing" v) metadata.hosts);
    syncthingAllList = builtins.attrNames syncthingEntries;
    sshPubkeyList = (zipAttrs (attrValues sshPubkeyEntries)).ssh-pubkey;
    magicDNS = hostSuffix: concatMapStringsSep "\n" (x: "${x}${hostSuffix}") ipv4HostsList;
    getInterface = host: metadataNoTypes."${host}".interface;
  };
}
