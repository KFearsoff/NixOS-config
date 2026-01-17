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
        order respond after reverse_proxy
      '';
      logFormat = ''
        level INFO
        format json
      '';

      extraConfig = ''
        (bad-method) {
          header allow "GET, HEAD"
          respond 405
        }

        (reverse-proxy) {
          reverse_proxy {args[0]} {
            header_up x-real-ip {remote_host}
          }
        }

        # TODO: migrate website to garage
        # (static-site) {
        #   uri path_regexp /$ /index.html
        #
        #   reverse_proxy <<wireguard/aman>>:8096 {
        #     rewrite /sites/{args[0]}{uri}
        #
        #     @not-found status 404
        #     handle_response @not-found {
        #       rewrite /sites/{args[0]}/404.html
        #       reverse_proxy <<wireguard/aman>>:8096 {
        #         replace_status 404
        #       }
        #     }
        #   }
        # }

        (skip-favicon-log) {
          log_skip /favicon.ico
        }

        (no-server-header) {
          header {
            -Server
            -Via
          }
        }

        (iocaine) {
          import mandatory-snippets

          @read method GET HEAD
          @not-read not {
            method GET HEAD
          }
          reverse_proxy @read 127.0.0.1:42069 {
            @fallback status 421
            # header_up x-request-id {http.request_id}
            handle_response @fallback {
              {blocks.handler}
            }
          }
          handle @not-read {
            {blocks.default}
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
          # import policies
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
        directories =
          lib.mkIf
            (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
            [
              {
                directory = config.services.caddy.dataDir;
                user = "caddy";
                group = "caddy";
                mode = "0700";
              }
            ];
      }
    ];
  };
}
