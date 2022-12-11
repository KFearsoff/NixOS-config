# This config file is largely copied from Ckie:
# https://github.com/ckiee/ckiesite-static/blob/3bbbc4d31691e9554c817d9bd8792e4e13a8e292/public/tailscale-coredns.md
# https://github.com/ckiee/nixfiles/tree/6d130dd21aab21792d775692218be2e073a6eb81/modules/services/coredns
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.coredns;
  hostSuffix = ".tailnet.nixchad.dev";

  # Taken from upstream: https://github.com/StevenBlack/hosts/blob/master/flake.nix
  alternatesList =
    lib.optional cfg.blockFakenews "fakenews"
    ++ lib.optional cfg.blockGambling "gambling"
    ++ lib.optional cfg.blockPorn "port"
    ++ lib.optional cfg.blockSocial "social";
  alternatesPath = "alternates/" + builtins.concatStringsSep "-" alternatesList + "/";

  combinedHosts = builtins.readFile ("${inputs.hosts}/"
    + lib.optionalString (alternatesList != []) alternatesPath
    + "hosts");
  excludeHosts = concatStringsSep "|" [".*kameleoon\..+"];
  patchedHosts = concatStringsSep "\n" (filter (x: ((builtins.match excludeHosts x) == null)) (splitString "\n" combinedHosts));
  magicDNS = config.lib.metadata.magicDNS hostSuffix;

  baseHosts = pkgs.writeTextFile {
    name = "coredns-hosts-nixchad";
    text = ''
      # Custom hosts
      ${patchedHosts}
      # Extra hosts
      ${cfg.extraHosts}
      # Imitate MagicDNS
      ${magicDNS}
    '';
  };
in {
  options.nixchad.coredns = {
    enable = mkEnableOption "CoreDNS server";

    interface = mkOption {
      type = types.str;
      description = "Local interface on which CoreDNS will bind";
      default = config.lib.metadata.getInterface config.networking.hostName;
    };

    extraHosts = mkOption {
      type = types.lines;
      default = "";
      description = "Extra hosts separated by lines";
    };

    blockFakenews = mkEnableOption "Additionally block fakenews hosts.";
    blockGambling = mkEnableOption "Additionally block gambling hosts.";
    blockPorn = mkEnableOption "Additionally block porn hosts.";
    blockSocial = mkEnableOption "Additionally block social hosts.";
  };

  config = mkIf cfg.enable {
    systemd.services.dns-hosts-update = {
      description = "Update the /run/coredns-hosts hosts file with new Tailscale hosts";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "dns-hosts-update" ''
          rm /run/coredns-hosts || true
          ln -s ${baseHosts} /run/coredns-hosts
        '';
      };
    };

    services.coredns = {
      enable = true;
      package = pkgs.coredns.override {
        externalPlugins = ["fanout"];
        vendorSha256 = "sha256-+YfJIowHNhRujOlvBxP70QkCpqpYHm7m0BtpIyOLFd8=";
      };

      config = ''
        . {
          prometheus 0.0.0.0:33003

          # Expose CoreDNS to localhost, local network and tailscale.
          # We can't bind to 0.0.0.0 (default) because we'll have conflicts with
          # systemd-resolved and dnsmasq (for libvirtd)
          bind lo ${cfg.interface} tailscale0

          hosts /run/coredns-hosts {
            reload 1500ms
            fallthrough
          }

          fanout . 127.0.0.1:5054 [::1]:5054 127.0.0.1:5055 [::1]:5055 127.0.0.1:5056 [::1]:5056
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

        box {
          prometheus 0.0.0.0:33003
          bind lo ${cfg.interface} tailscale0
          file ${./box.zone}
        }
      '';
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

    services.prometheus.scrapeConfigs = [
      {
        job_name = "coredns";
        static_configs = [
          {
            targets = map (x: "${x}:33003") config.lib.metadata.hostList;
          }
        ];
      }
    ];

    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [53 33003];
      allowedUDPPorts = [53 33003];
    };

    networking.firewall.interfaces."${cfg.interface}" = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
}
