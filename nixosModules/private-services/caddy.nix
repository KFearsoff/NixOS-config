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
    };

    environment.etc."alloy/caddy.alloy".text = ''
      scrape_url "caddy" {
        name = "caddy"
        url  = "localhost:2019"
      }

      local.file_match "caddy" {
        path_targets = [{"__path__" = "/var/log/caddy/*.log", "job" = "caddy", "hostname" = constants.hostname}]
      }

      loki.source.file "caddy" {
        targets = local.file_match.caddy.targets
        forward_to = [loki.write.default.receiver]
        tail_from_end = true
      }
    '';
    systemd.services.alloy.serviceConfig.SupplementaryGroups = [ "caddy" ];

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
