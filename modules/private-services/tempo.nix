{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.tempo;
  tempoHttpPort = 33102;
  tempoGrpcPort = 33112;
  receiverHttpPort = 33103;
  receiverGrpcPort = 33113;
in {
  options.nixchad.tempo = {
    enable = mkEnableOption "Tempo tracing storage";
  };

  config = mkIf cfg.enable {
    services.tempo = {
      enable = true;
      settings = {
        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = tempoHttpPort;
          grpc_listen_address = "0.0.0.0";
          grpc_listen_port = tempoGrpcPort;
        };
        usage_report.reporting_enabled = false;

        distributor.receivers.otlp.protocols.http.endpoint = "0.0.0.0:${toString receiverHttpPort}";
        distributor.receivers.otlp.protocols.grpc.endpoint = "0.0.0.0:${toString receiverGrpcPort}";

        storage.trace = {
          backend = "local";
          wal.path = "/var/lib/tempo/wal";
          local.path = "/var/lib/tempo/blocks";
        };
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [receiverGrpcPort];
  };
}
