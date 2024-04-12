{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.alertmanager;
  alertmanagerPort = config.services.prometheus.alertmanager.port;
in {
  options.nixchad.alertmanager = {
    enable = mkEnableOption "Alertmanager alerting";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      alertmanager = {
        enable = true;
        environmentFile = "/secrets/telegram";
        webExternalUrl = "https://alertmanager.nixalted.com";

        configuration = {
          route = {
            receiver = "telegram";
            group_by = ["severity"];
            routes = [
              {
                matchers = ["alertname =~ HostMemoryIsUnderUtilized|HostCpuIsUnderUtilized"];
                repeat_interval = "1w";
              }
            ];
          };

          receivers = [
            {
              name = "telegram";
              telegram_configs = [
                {
                  api_url = "https://api.telegram.org";
                  bot_token = "$BOT_TOKEN"; # substituted from environmentFile
                  chat_id = -1001864190705; # private channel
                  parse_mode = "HTML"; # https://github.com/prometheus/alertmanager/issues/2866
                  disable_notifications = true;
                }
              ];
            }
          ];
        };
      };

      alertmanagers = [
        {
          static_configs = [
            {
              targets = [
                "localhost:${toString alertmanagerPort}"
              ];
            }
          ];
        }
      ];
    };
  };
}
