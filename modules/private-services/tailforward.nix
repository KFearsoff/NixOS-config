{
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.tailforward;
  port = "54321";
in {
  options.nixchad.tailforward = {
    enable = mkEnableOption "Tailforward, a self-written Rust program to send Tailscale webhook events to Telegram";
  };

  config = mkIf cfg.enable {
    systemd.services.tailforward = {
      after = ["network.target"];
      wants = ["network.target"];
      wantedBy = ["default.target"];
      serviceConfig.ExecStart = "${inputs.tailforward.packages.x86_64-linux.default}/bin/tailforward";
      environment = {
        TAILFORWARD_ADDRESS = "127.0.0.1:${port}";
      };
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
