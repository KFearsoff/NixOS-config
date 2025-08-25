{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.reverseProxy;
  toCaddyVirtualHosts = name: val: {
    logFormat = ''
      output file ${config.services.caddy.logDir}/access-${name}.log {
        mode 0640
      }
    '';
    extraConfig =
      if (val.extraConfig == null) then
        ''
          reverse_proxy unix//run/anubis/anubis-${name}.sock {
            header_up X-Real-Ip {remote_host}
            header_up X-Http-Version {http.request.proto}
          }
        ''
      else
        val.extraConfig;
  };
  toAnubisVirtualHosts = _: val: {
    settings.TARGET = val.reverseProxy;
  };
in
{
  options.nixchad.reverseProxy = {
    enable = mkEnableOption "reverse proxy abstraction";

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
