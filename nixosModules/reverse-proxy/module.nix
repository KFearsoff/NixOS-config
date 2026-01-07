{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.nixchad.reverseProxy;
  toCaddyVirtualHosts = _: val: {
    logFormat = "";
    extraConfig =
      let
        snippets = lib.lists.forEach val.snippets (i: "import ${i}") |> lib.strings.concatLines;
        proxy = ''
          import iocaine {
            handler {
              ${snippets}
              import reverse-proxy ${val.reverseProxy}
            }
            default {
              ${snippets}
              import reverse-proxy ${val.reverseProxy}
            }
          }
        '';
      in
      if (val.extraConfig == null) then
        ''
          tracing {
            span {host}
          }
          ${proxy}
        ''
      else
        val.extraConfig;
  };
in
{
  options.nixchad.reverseProxy = {
    enable = mkEnableOption "reverse proxy abstraction built on top of Caddy";

    virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              hostName = mkOption {
                type = types.str;
                default = name;
              };
              extraConfig = mkOption {
                type = types.nullOr types.lines;
                default = null;
              };
              reverseProxy = mkOption {
                type = types.nullOr types.str;
                default = null;
              };
              enableIocaine = mkEnableOption "Iocaine integration" // {
                default = true;
              };
              snippets = mkOption {
                type = types.listOf types.str;
                default = [
                  "default-snippets"
                ];
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    services = {
      caddy.virtualHosts = mapAttrs toCaddyVirtualHosts cfg.virtualHosts;

      iocaine = {
        enable = true;
        environment."RUST_LOG" = "error,iocaine=info";
        config = {
          server.main = {
            bind = "127.0.0.1:42069";
            mode = "http";
            use.handler-from = "nsoe";
            use.metrics = "metrics";
            "initial-seed-file" = "/run/current-system/boot.json";
          };
          server.metrics = {
            bind = "127.0.0.1:42042";
            mode = "prometheus";
            persist-path = "metrics-nsoe.json";
          };
          handler.nsoe.path = "${pkgs.nam-shub-of-enki}";
          handler.nsoe.config = {
            inherits = "default";
            checks.ai-robots-txt.path = "${inputs.ai-robots-txt}/robots.json";
            checks.demo-host.host = "poison.nixalted.com";
            sources = {
              "wordlists" = [ "${pkgs.miscfiles}/share/web2" ];
              training-corpus =
                let
                  bee-movie = pkgs.bee-movie-script;
                  inherit (pkgs) brave-new-world;
                  # modest-proposal = pkgs.modest-proposal;
                  inherit (pkgs) orwell-1984;
                in
                [
                  "${bee-movie}"
                  "${brave-new-world}"
                  # FIXME: it's broken
                  # "{modest-proposal}"
                  "${orwell-1984}"
                ];
            };
          };
        };
      };
    };

    # nixchad.impermanence.persisted.values = [
    #   {
    #     directories =
    #       lib.mkIf
    #         (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
    #         [
    #           {
    #             directory = "/var/lib/private/iocaine"; # backup the whole dir recursively
    #           }
    #         ];
    #   }
    # ];

    environment.etc."alloy/iocaine.alloy".text = ''
      scrape_url "iocaine" {
        name = "iocaine"
        url  = "localhost:42042"
      }
    '';
  };
}
