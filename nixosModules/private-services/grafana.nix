{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.grafana;
  mkDatasource = type: url: extraConfig:
    {
      name = type;
      inherit type;
      uid = "provisioned_uid_${type}";
      inherit url;
    }
    // extraConfig;
  grafanaPort = config.services.grafana.settings.server.http_port;
  domain = "grafana.nixalted.com";
in {
  options.nixchad.grafana = {
    enable = mkEnableOption "Grafana dashboard";
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server.root_url = "https://${domain}";
        analytics.reporting_enabled = false;

        database = {
          type = "postgres";
          user = "grafana";
          host = "/run/postgresql";
          name = "grafana";
          password = "";
        };

        "auth.github" = {
          enabled = true;
          client_id = "$__file{/secrets/github_client_id}";
          client_secret = "$__file{/secrets/github_client_secret}";
          role_attribute_path = "[login=='KFearsoff'][0] && 'Admin' || 'Viewer'";
        };
        "auth.basic" = {
          enabled = false;
        };
        auth.disable_login_form = true;

        "tracing.opentelemetry.otlp".address = "localhost:4317";
      };

      provision = {
        enable = true;

        datasources.settings = {
          datasources = [
            (mkDatasource "prometheus" "http://localhost:9090" {
              jsonData = {
                exemplarTraceIdDestinations = {
                  datasourceUid = "provisioned_uid_tempo";
                  traceIdLabelName = "traceID";
                };
              };
            })
            (mkDatasource "loki" "http://localhost:33100" {
              jsonData = {
                derivedFields = [
                  {
                    datasourceUid = "provisioned_uid_tempo";
                    matcherRegex = "(?:traceID|traceId|trace_id)=(\\w+)";
                    name = "TraceID";
                    url = "$${__value.raw}";
                    urlDisplayLabel = "View Trace";
                  }
                ];
              };
            })
            (mkDatasource "tempo" "http://localhost:33102" {
              jsonData = {
                tracesToLogsV2 = {
                  datasourceUid = "provisioned_uid_loki";
                  spanStartTimeShift = "-5m";
                  spanEndTimeShift = "5m";
                  filterByTraceID = false;
                  filterBySpanID = false;
                };
                serviceMap = {
                  datasourceUid = "provisioned_uid_prometheus";
                };
                nodeGraph = {
                  enabled = true;
                };
                lokiSearch = {
                  datasourceUid = "provisioned_uid_loki";
                };
              };
            })
            (mkDatasource "alertmanager" "http://localhost:${toString config.services.prometheus.alertmanager.port}" {
              jsonData = {
                implementation = "prometheus";
                handleGrafanaManagedAlerts = true;
              };
            })
          ];
        };
      };
    };

    services.postgresql = {
      ensureDatabases = ["grafana"];
      ensureUsers = [
        {
          name = "grafana";
          ensureDBOwnership = true;
        }
      ];
    };
    nixchad = {
      impermanence.persisted.values = [
        {
          directories =
            lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
            [
              {
                directory = config.services.grafana.dataDir;
                user = "grafana";
                group = "grafana";
              }
            ];
        }
      ];

      nginx.vhosts."grafana" = {
        websockets = true;
        port = grafanaPort;
      };

      grafana-agent.metrics_scrape_configs = [
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [
                "localhost:${toString grafanaPort}"
              ];
            }
          ];
        }
      ];
    };
  };
}
