{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.caddy;
in
{
  options.nixchad.caddy = {
    enable = mkEnableOption "Caddy";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      globalConfig = ''
        metrics {
          per_host
        }
      '';
      logFormat = ''
        level INFO
        format json
      '';

      extraConfig = ''
        (skip-favicon-log) {
          log_skip /favicon.ico
        }

        (no-server-header) {
          header {
            -Server
            -Via
          }
        }

        (search-engine-opt-out) {
          header {
            +x-robots-tag: "noindex, nofollow, nosnippet, noimageindex, noarchive, nocache, notranslate"
          }
        }

        (robots-txt) {
          @robotstxt path /robots.txt
          respond @robotstxt 200 {
            body <<TXT
            User-Agent: *
            Disallow: /

            TXT
          }
        }

        (compress) {
          encode zstd gzip
        }

        # https://pages.madhouse-project.org/algernon/infrastructure.org/services_caddy_snippets_policies
        (policies) {
          header {
            >Permission-Policy "interest-cohort=(), browsing-topics=()"
            >Referrer-Policy "no-referrer"
            >X-Content-Type-Options "nosniff"
            >Content-Security-Policy "frame-ancestors 'self'"
          }
        }

        (mandatory-snippets) {
          import skip-favicon-log
          import no-server-header
        }

        (recommended-snippets) {
          import search-engine-opt-out
          import robots-txt
          import compress
        }

        (default-snippets) {
          import recommended-snippets
          import policies
        }
      '';
    };

    environment.etc."alloy/caddy.alloy".text = ''
      scrape_url "caddy" {
        name = "caddy"
        url  = "localhost:2019"
      }
    '';
    systemd.services.caddy.serviceConfig = {
      SupplementaryGroups = [ "anubis" ]; # to access Anubis sockets
      Environment = "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://localhost:4317 OTEL_SERVICE_NAME=caddy";
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [
      80
      443
    ];

    nixchad.impermanence.persisted.values = [
      {
        directories = lib.mkIf (
          config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services
        ) [ config.services.caddy.dataDir ];
      }
    ];
  };
}
