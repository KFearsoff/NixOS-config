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
      domains = ["tailnet.nixchad.dev"];
      fallbackDns = ["9.9.9.9" "8.8.8.8" "1.1.1.1"];
      dnssec = "false"; # we already DNSSEC on CoreDNS
    };
    networking.nameservers = ["127.0.0.1"];

    # https://libredd.it/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a/
    #systemd.targets.network-online.wantedBy = pkgs.lib.mkForce []; # Normally ["multi-user.target"]
    #systemd.services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce []; # Normally ["network-online.target"]

    networking.networkmanager.enable = true;
    services.tailscale.enable = true;
    networking.firewall.checkReversePath = "loose";

    environment.persistence."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/tailscale"
      ];
    };
  };
}
