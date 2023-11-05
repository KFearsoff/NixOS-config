{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.tailforward;
  port = "54321";
  configFile = pkgs.writeText "tailforward.toml" ''
    debug = false
    address = "127.0.0.1:${port}"

    [tailscale]
    secret_file = "/secrets/tailscale-webhook"

    [telegram]
    secret_file = "/secrets/telegram"
    file_format = "Alertmanager"
    chat_id = -1001864190705
  '';
in {
  options.nixchad.tailforward = {
    enable = mkEnableOption "Tailforward, a self-written Rust program to send Tailscale webhook events to Telegram";
  };

  config = mkIf cfg.enable {
    systemd.services.tailforward = {
      after = ["network.target"];
      wants = ["network.target"];
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${inputs.tailforward.packages.x86_64-linux.default}/bin/tailforward";
        ConfigurationDirectory = "tailforward";
      };
      environment = {
        OTEL_SERVICE_NAME = "tailforward";
      };
    };

    environment.etc = {
      "tailforward/tailforward.toml".source = configFile;
    };

    services.nginx = {
      virtualHosts."nixalted.com" = {
        forceSSL = true;
        useACMEHost = "nixalted.com";

        locations."/tailscale-webhook" = {
          proxyPass = "http://127.0.0.1:${port}";
          extraConfig = ''
            allow all;
          '';
        };
      };
    };
  };
}
