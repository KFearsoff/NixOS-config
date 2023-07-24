{
  config,
  lib,
  pkgs,
  servername,
  ...
}:
with lib; let
  cfg = config.nixchad.nginx;
  hostname = config.networking.hostName;
  exporter-port = 33001;
  domainBase = "nixalted.com";
  collectVhosts = lib.mapAttrs' (name: val: lib.nameValuePair "${name}.${domainBase}" (vhostBase val)) cfg.vhosts;
  vhostBase = opts: {
    forceSSL = true;
    useACMEHost = domainBase;
    quic = true;
    kTLS = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString opts.port}";
      proxyWebsockets = opts.websockets;
    };

    inherit (opts) extraConfig;
  };
in {
  options.nixchad.nginx = {
    enable = mkEnableOption "nginx";

    vhosts = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          websockets = mkEnableOption "websocket proxying";
          port = mkOption {
            type = types.ints.u16;
          };
          extraConfig = mkOption {
            type = types.lines;
            default = ''
              allow 100.0.0.0/8;
              deny  all;
            '';
          };
          domain = mkOption {
            type = types.str;
            default = "${name}.${domainBase}";
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = hostname == servername;
        message = ''
          You are trying to deploy private services on the wrong machine.
          If that's not true, change "servername" in flake.nix.
        '';
      }
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "services-nixchad@riseup.net";

      certs."${domainBase}" = {
        dnsProvider = "namecheap";
        extraDomainNames = lib.mapAttrsToList (_: val: val.domain) cfg.vhosts;
        group = "nginx";
        credentialsFile = "/secrets/acme";
      };
    };

    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;

      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;

      statusPage = true;
      enableReload = true;

      resolver.addresses = ["127.0.0.1:53"];
      proxyResolveWhileRunning = true;

      virtualHosts = collectVhosts;
    };

    services.prometheus.exporters.nginx = {
      enable = true;
      port = exporter-port;
    };

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "nginx";
        static_configs = [
          {
            targets = [
              "localhost:${toString exporter-port}"
            ];
          }
        ];
      }
    ];

    networking.firewall.allowedTCPPorts = [80 443];
    networking.firewall.allowedUDPPorts = [80 443];

    nixchad.impermanence.persisted.values = [
      {
        directories =
          lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
          ["/var/lib/acme"]; # FIXME: Is this more correct than the snippet below?
        #directories = builtins.map (x: x.directory) (builtins.attrValues cfg);
      }
    ];
  };
}
