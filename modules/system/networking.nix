{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.networking;
in {
  options.nixchad.networking = {
    enable = mkEnableOption "networking";
  };

  config = mkIf cfg.enable {
    services.resolved = {
      enable = true;
      fallbackDns = ["9.9.9.9" "8.8.8.8" "1.1.1.1"];
      dnssec = "false"; # we already DNSSEC on CoreDNS
    };
    networking.nameservers = ["100.100.14.2"];

    # https://libredd.it/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a/
    #systemd.targets.network-online.wantedBy = pkgs.lib.mkForce []; # Normally ["multi-user.target"]
    #systemd.services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce []; # Normally ["network-online.target"]

    networking.networkmanager.enable = mkDefault true;
    services.tailscale.enable = true;

    nixchad.impermanence.persisted.values =
      (lib.optional (config.nixchad.impermanence.presets.enable && config.nixchad.impermanence.presets.essential)
        {
          directories = ["/etc/NetworkManager/system-connections"];
          files = [
            "/var/lib/NetworkManager/secret_key"
            "/var/lib/NetworkManager/seen-bssids"
            "/var/lib/NetworkManager/timestamps"
          ]; # Why those files?
        })
      ++ (lib.optional (config.nixchad.impermanence.presets.enable && config.nixchad.impermanence.presets.system) {
        directories = ["/var/lib/tailscale"];
      });
  };
}
