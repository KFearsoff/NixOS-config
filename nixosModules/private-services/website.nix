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
        extraConfig = ''
          tracing {
            span "nixalted.com"
          }
          import iocaine {
            handler {
              import default-snippets
              import reverse-proxy /tailscale-webhook :54321
              root * /etc/website
              file_server
            }
            default {
              import default-snippets
              import reverse-proxy /tailscale-webhook :54321
              import bad-method
            }
          }
        '';
      };
    };
  };
}
