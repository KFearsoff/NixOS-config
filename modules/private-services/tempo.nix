{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.tempo;
  tempoHttpPort = 33102;
  tempoGrpcPort = 33112;
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
        distributor.receivers.otlp.protocols.grpc.endpoint = "0.0.0.0:4317";
        distributor.receivers.otlp.protocols.http.endpoint = "0.0.0.0:4318";
        storage.trace = {
          backend = "local";
          wal.path = "/var/lib/tempo/wal";
          local.path = "/var/lib/tempo/blocks";
        };
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [4317 4318];
  };
}
