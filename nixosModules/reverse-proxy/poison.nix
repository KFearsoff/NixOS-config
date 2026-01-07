{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.reverseProxy;
  domain = "poison.nixalted.com";
in
{
  config = mkIf cfg.enable {
    nixchad.reverseProxy.virtualHosts = {
      "poison.nixalted.com" = {
        extraConfig = ''
          tracing {
            span ${domain}
          }
          import iocaine {
            handler {
              import default-snippets
            }
            default {
              import default-snippets
              import bad-method
            }
          }
        '';
      };
    };
  };
}
