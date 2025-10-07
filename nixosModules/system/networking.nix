{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.networking;
  cloudflare = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];
  quad9 = [
    "9.9.9.9"
    "149.112.112.112"
    "2620:fe::fe"
    "2620:fe::9"
  ];
  google = [
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];
  addDomain = domain: servers: builtins.map (x: x + "#" + domain) servers;
  cloudflare-tls = addDomain "cloudflare-dns.com" cloudflare;
  quad9-tls = addDomain "dns.quad9.net" quad9;
  google-tls = addDomain "dns.google" google;
in
{
  options.nixchad.networking = {
    enable = mkEnableOption "networking";
  };

  config = mkIf cfg.enable {
    services.resolved = {
      enable = true;
      fallbackDns = cloudflare ++ quad9 ++ google;
      dnssec = "true";
      # extraConfig = ''
      #   DNSOverTLS=true
      # '';
    };
    # networking.nameservers = cloudflare-tls ++ quad9-tls ++ google-tls;
    networking.nameservers = cloudflare ++ quad9 ++ google;

    # systemd.services.NetworkManager-wait-online.requires = ["persist-persist-var-lib-NetworkManager-seen\x2dbssids.service" "persist-persist-var-lib-NetworkManager-timestamps.service"];
    systemd.services.NetworkManager.requires = [
      "persist-persist-var-lib-NetworkManager-seen\\x2dbssids.service"
      "persist-persist-var-lib-NetworkManager-timestamps.service"
    ];
    systemd.services.NetworkManager.after = [
      "persist-persist-var-lib-NetworkManager-seen\\x2dbssids.service"
      "persist-persist-var-lib-NetworkManager-timestamps.service"
    ];

    networking.networkmanager.enable = mkDefault true;
    services.tailscale.enable = true;

    nixchad.impermanence.persisted.values =
      (lib.optional
        (config.nixchad.impermanence.presets.enable && config.nixchad.impermanence.presets.essential)
        {
          directories = [ "/etc/NetworkManager/system-connections" ];
          files = [
            "/var/lib/NetworkManager/secret_key"
            "/var/lib/NetworkManager/seen-bssids"
            "/var/lib/NetworkManager/timestamps"
          ]; # Why those files?
        }
      )
      ++ (lib.optional
        (config.nixchad.impermanence.presets.enable && config.nixchad.impermanence.presets.system)
        {
          directories = [ "/var/lib/tailscale" ];
        }
      );
  };
}
