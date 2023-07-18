{
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.tailforward;
  port = "33010";
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
      environment = {RUST_LOG = "info,tower_http=info";};
    };

    services.nginx = {
      virtualHosts."nixalted.com" = {
        forceSSL = true;
        useACMEHost = "nixalted.com";

        locations."/tailscale-webhook" = {
          proxyPass = "http://localhost:${port}/";
          extraConfig = ''
            allow all;
          '';
        };
      };
    };
  };
}
