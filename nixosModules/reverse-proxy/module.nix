{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.reverseProxy;
  toCaddyVirtualHosts = name: val: {
    logFormat = "";
    extraConfig =
      let
        snippets = lib.lists.forEach val.snippets (i: "import ${i}") |> lib.strings.concatLines;
      in
      if (val.extraConfig == null) then
        ''
          ${snippets}
          tracing {
            span {host}
          }
          reverse_proxy unix//run/anubis/anubis-${name}/anubis.sock {
            header_up X-Real-Ip {remote_host}
            header_up X-Http-Version {http.request.proto}
          }
        ''
      else
        val.extraConfig;
  };
  toAnubisVirtualHosts = name: val: {
    settings = {
      TARGET = val.reverseProxy;
      BIND = "/run/anubis/anubis-${name}/anubis.sock";
      METRICS_BIND = "/run/anubis/anubis-${name}/anubis-metrics.sock";
    };
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
              enableAnubis = mkEnableOption "Anubis proxying" // {
                default = true;
              };
              snippets = mkOption {
                type = types.listOf types.str;
                default = [ "default-snippets" ];
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
      anubis.instances =
        filterAttrs (_: v: v.enableAnubis) cfg.virtualHosts |> mapAttrs toAnubisVirtualHosts;
      anubis.defaultOptions.settings = {
        DIFFICULTY = 5;
        OG_PASSTHROUGH = true;
        SERVE_ROBOTS_TXT = true;
      };
    };
  };
}
