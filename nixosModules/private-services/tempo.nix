{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.tempo;
  tempoHttpPort = 33102;
  tempoGrpcPort = 33112;
  receiverHttpPort = 33103;
  receiverGrpcPort = 33113;
in
{
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
        metrics_generator.storage = {
          path = "/var/lib/tempo/generator/wal";
          remote_write = [
            {
              url = "http://localhost:${toString config.services.prometheus.port}/api/v1/push";
            }
          ];
        };
        live_store = {
          shutdown_marker_dir = "/var/lib/tempo/live-store/shutdown-marker";
          wal.path = "/var/lib/tempo/live-store/traces";
        };
        block_builder.wal.path = "/var/lib/tempo/block-builder/wal";
        backend_scheduler.local_work_path = "/var/lib/tempo";
        overrides.defaults.metrics_generator.processors = [
          "service-graphs"
          "span-metrics"
          "host-info"
        ];
      };
    };

    systemd.services = {
      alloy.after = [ "tempo.service" ];
      tempo = {
        serviceConfig = {
          MemoryHigh = 300 * 1024 * 1024; # 300MiB
          MemoryMax = 500 * 1024 * 1024; # 500MiB
          CPUQuota = "50%";
        };
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ receiverGrpcPort ];
  };
}
