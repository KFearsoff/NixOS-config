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
      serviceConfig.ExecStart = "${inputs.tailforward.packages.x86_64-linux.default}/bin/ts_to_tg";
      environment = {RUST_LOG = "tower_http=trace,debug,info";};
    };

    services.nginx = {
      virtualHosts."nixalted.com" = {
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
