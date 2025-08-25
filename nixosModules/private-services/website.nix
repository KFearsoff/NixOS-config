{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.website;
in
{
  options.nixchad.website = {
    enable = mkEnableOption "my personal website";
  };

  config = mkIf cfg.enable {
    environment.etc.website.source = "${inputs.website.packages.x86_64-linux.default}";

    nixchad.reverseProxy.virtualHosts = {
      "nixalted.com" = {
        reverseProxy = "http://localhost:54320";
        extraConfig = ''
          tracing {
            span "nixalted.com"
          }
          reverse_proxy /tailscale-webhook :54321
          reverse_proxy unix//run/anubis/anubis-nixalted.com/anubis-nixalted.com.sock {
            header_up X-Real-Ip {remote_host}
            header_up X-Http-Version {http.request.proto}
          }
        '';
      };
      ":54320" = {
        enableAnubis = false;
        extraConfig = ''
          tracing {
            span "website"
          }
          root * /etc/website
          file_server
        '';
      };
    };
  };
}
