{
  config,
  lib,
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

    locations."/" = {
      proxyPass = "http://localhost:${toString opts.port}";
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
            default = name;
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

      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      recommendedZstdSettings = true;

      statusPage = true;
      virtualHosts = collectVhosts;
    };

    services.prometheus.exporters.nginx = {
      enable = true;
      port = exporter-port;
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "nginx";
        static_configs = [
          {
            targets = [
              "localhost:${toString exporter-port}" # nginx
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
