{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.paperless;
  domain = "paperless.nixalted.com";
in
{
  options.nixchad.paperless = {
    enable = mkEnableOption "Paperless";
  };

  config = mkIf cfg.enable {
    services = {
      paperless = {
        enable = true;
        database.createLocally = true;
        passwordFile = "/secrets/paperless-password";
        inherit domain;
        settings = {
          PAPERLESS_ADMIN_USER = "admin";
          PAPERLESS_OCR_LANGUAGE = "eng+rus+kat+spa";
          PAPERLESS_ENABLE_COMPRESSION = false; # Compression is done in Caddy
        };
      };
    };

    nixchad.reverseProxy.virtualHosts = {
      "${domain}" = {
        reverseProxy = "http://localhost:${toString config.services.paperless.port}";
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
                  directory = config.services.paperless.dataDir;
                  user = config.services.paperless.user;
                  group = "paperless";
                }
              ];
        }
      ];
    };
  };
}
