{lib, ...}:
with lib; let
  metadata = importTOML ../hosts/metadata.toml;
  metadataTypes = builtins.attrNames metadata;
  metadataNoTypes = builtins.foldl' (x: y: x // metadata."${y}") {} metadataTypes;
  syncthingEntries = filterAttrs (n: builtins.hasAttr "syncthing") metadataNoTypes;
  sshPubkeyEntries = filterAttrs (n: builtins.hasAttr "ssh-pubkey") metadataNoTypes;
  ipv4Entries = filterAttrs (n: builtins.hasAttr "ipv4") metadataNoTypes;
  ipv4HostsList = mapAttrsToList (n: v: "${v.ipv4} ${n}") ipv4Entries;
in {
  lib.metadata = {
    inherit metadata;
    syncthingDevicesConfig = mapAttrs (n: v: v.syncthing // {addresses = ["tcp://${n}" "quic://${n}"];}) syncthingEntries;
    syncthingHostsList = builtins.attrNames (filterAttrs (n: builtins.hasAttr "syncthing") metadata.hosts);
    syncthingAllList = builtins.attrNames syncthingEntries;
    sshPubkeyList = (zipAttrs (attrValues sshPubkeyEntries)).ssh-pubkey;
    magicDNS = hostSuffix: concatMapStringsSep "\n" (x: "${x}${hostSuffix}") ipv4HostsList;
    getInterface = host: metadataNoTypes."${host}".interface;
    hasIpv4 = host: builtins.hasAttr "ipv4" metadataNoTypes."${host}";
    hasIpv6 = host: builtins.hasAttr "ipv6" metadataNoTypes."${host}";
  };
}
