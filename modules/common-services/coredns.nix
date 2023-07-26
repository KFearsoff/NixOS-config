# This config file is largely copied from Ckie:
# https://github.com/ckiee/ckiesite-static/blob/3bbbc4d31691e9554c817d9bd8792e4e13a8e292/public/tailscale-coredns.md
# https://github.com/ckiee/nixfiles/tree/6d130dd21aab21792d775692218be2e073a6eb81/modules/services/coredns
{
  config,
  lib,
  #pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.coredns;
in {
  options.nixchad.coredns = {
    enable = mkEnableOption "CoreDNS server";
  };

  config = mkIf cfg.enable {
    services.coredns = {
      enable = true;
      #package = pkgs.coredns.override {
      #  externalPlugins = ["fanout"];
      #  vendorSha256 = "sha256-+YfJIowHNhRujOlvBxP70QkCpqpYHm7m0BtpIyOLFd8=";
      #};

      config = ''
        . {
          prometheus 0.0.0.0:33003

          # Expose CoreDNS to localhost and tailscale.
          # We can't bind to 0.0.0.0 (default) because we'll have conflicts with
          # systemd-resolved and dnsmasq (for libvirtd)
          bind lo tailscale0

          forward . 127.0.0.1:5054 [::1]:5054 127.0.0.1:5055 [::1]:5055 127.0.0.1:5056 [::1]:5056
          errors
          cache {
            prefetch 10
          }
        }

        .:5054 {
          forward . tls://1.1.1.1 tls://1.0.0.1 tls://2606:4700:4700::1111 tls://2606:4700:4700::1001 {
            tls_servername cloudflare-dns.com
          }
        }

        .:5055 {
          forward . tls://9.9.9.9 tls://149.112.112.112 tls://2620:fe::fe tls://2620:fe::9 {
            tls_servername dns.quad9.net
          }
        }

        .:5056 {
          forward . tls://8.8.8.8 tls://8.8.4.4 tls://2001:4860:4860::8888 tls://2001:4860:4860::8844 {
            tls_servername dns.google
          }
        }
      '';
    };

    networking.firewall.interfaces.tailscale0 = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53];
    };

    systemd.services.coredns = {
      # Tailscale gets confused if it's launched with CoreDNS in parallel.
      # It will spam "dns udp query: context deadline exceeded". To make
      # Tailscale happy, we launch CoreDNS first (failing it, since it needs
      # interface tailscale0 to be up) and then restart it
      # TODO: check if issue persists after turning off MagicDNS
      before = ["tailscaled.service"];
      serviceConfig.RestartSec = "5s";
    };

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "coredns";
        static_configs = [
          {
            targets = [
              "localhost:33003"
            ];
          }
        ];
      }
    ];
  };
}
