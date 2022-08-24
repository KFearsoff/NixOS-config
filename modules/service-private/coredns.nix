{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.coredns;
  hostname = config.networking.hostName;
in {
  options.nixchad.coredns = {
    enable = mkEnableOption "CoreDNS server";
  };

  config = mkIf cfg.enable {
    services.coredns = {
      enable = true;

      config = ''
        .:5053 {
          prometheus localhost:33003
          forward . 127.0.0.1:5054 127.0.0.1:5055 127.0.0.1:5056
          errors
          cache
        }

        .:5054 {
          forward . 1.1.1.1 1.0.0.1 {
            tls_servername cloudflare-dns.com
          }
        }

        .:5055 {
          forward . 9.9.9.9 149.112.112.112 {
            tls_servername dns.quad9.net
          }
        }

        .:5056 {
          forward . 8.8.8.8 8.8.4.4 {
            tls_servername dns.google
          }
        }

        me:5053 {
          prometheus localhost:33003
          file ${./me.zone}
        }
      '';
    };

    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [5053];
      allowedUDPPorts = [5053];
    };

    networking.nameservers = mkForce ["127.0.0.1:5053"];
  };
}
