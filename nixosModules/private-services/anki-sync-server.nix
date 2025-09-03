{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.anki-sync-server;
  ankiPort = config.services.anki-sync-server.port;
in
{
  options.nixchad.anki-sync-server = {
    enable = mkEnableOption "Anki sync server";
  };

  config = mkIf cfg.enable {
    services.anki-sync-server = {
      enable = true;
      address = "127.0.0.1";
      users = [
        {
          username = "kfears";
          passwordFile = "/secrets/kfears-anki";
        }
        {
          username = "mari";
          passwordFile = "/secrets/mari-anki";
        }
        {
          username = "shared";
          passwordFile = "/secrets/shared-anki";
        }
      ];
    };
    systemd.services.anki-sync-server.serviceConfig.DynamicUser = lib.mkForce false;

    nixchad.reverseProxy.virtualHosts = {
      "anki.nixalted.com" = {
        reverseProxy = "http://localhost:${toString ankiPort}";
      };
    };

    nixchad = {
      impermanence.persisted.values = [
        {
          directories =
            lib.mkIf
              (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
              [
                {
                  directory = "/var/lib/anki-sync-server";
                }
              ];
        }
      ];
    };
  };
}
