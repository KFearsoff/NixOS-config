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

    services.caddy.virtualHosts."nixalted.com" = {
      logFormat = ''
        output file ${config.services.caddy.logDir}/access-nixalted.com.log {
          mode 0640
        }
      '';
      extraConfig = ''
        root * /etc/website
        reverse_proxy /tailscale-webhook :54321
        file_server
      '';
    };
  };
}
