# This config file is largely copied from Ckie:
# https://github.com/ckiee/ckiesite-static/blob/3bbbc4d31691e9554c817d9bd8792e4e13a8e292/public/tailscale-coredns.md
# https://github.com/ckiee/nixfiles/tree/6d130dd21aab21792d775692218be2e073a6eb81/modules/services/coredns
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.coredns;
  baseHosts = pkgs.writeTextFile {
    name = "coredns-hosts-nixchad";
    text = ''
      # Runtime hosts
    '';
  };
  hostSuffix = ".tailnet.nixchad.dev";
in {
  options.nixchad.coredns = {
    enable = mkEnableOption "CoreDNS server";

    # TODO: infer the interface automatically
    interface = mkOption {
      type = types.str;
      description = "Local interface on which CoreDNS will bind";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dns-hosts-poller = {
      description = "Update the /run/coredns-hosts hosts file with new Tailscale hosts";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart =
          pkgs.runCommandLocal "dns-hosts-poller" {
            inherit (pkgs) bash tailscale jq;
            inherit baseHosts hostSuffix;
          } ''
            substituteAll "${./dns-hosts-poller.sh}" "$out"
            chmod +x "$out"
          '';
      };

      preStart = ''
        rm /run/coredns-hosts || true
        ln -s ${baseHosts} /run/coredns-hosts
      '';
    };

    services.coredns = {
      enable = true;

      config = ''
        . {
          prometheus localhost:33003

          # Expose CoreDNS to localhost, local network and tailscale.
          # We can't bind to 0.0.0.0 (default) because we'll have conflicts with
          # systemd-resolved and dnsmasq (for libvirtd)
          bind lo ${cfg.interface} tailscale0

          hosts /run/coredns-hosts {
            reload 1500ms
            fallthrough
          }

          forward . 127.0.0.1:5054 [::1]:5054 127.0.0.1:5055 [::1]:5055 127.0.0.1:5056 [::1]:5056
          errors
          cache
        }

        .:5054 {
          forward . 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001 {
            tls_servername cloudflare-dns.com
          }
        }

        .:5055 {
          forward . 9.9.9.9 149.112.112.112 2620:fe::fe 2620:fe::9 {
            tls_servername dns.quad9.net
          }
        }

        .:5056 {
          forward . 8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844 {
            tls_servername dns.google
          }
        }

        me {
          prometheus localhost:33003
          bind lo ${cfg.interface} tailscale0
          file ${./me.zone}
        }
      '';
    };

    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };

    networking.firewall.interfaces."${cfg.interface}" = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
}