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
  grafanaPort = toString config.services.grafana.settings.server.http_port;
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

        "auth.proxy" = {
          enabled = true;
          header_name = "X-Webauth-User";
          header_property = "username";
          auto_sign_up = true;
          sync_ttl = 60;
          whitelist = "127.0.0.1";
          headers = "Name:X-Webauth-User";
          enable_login_token = true;
        };

        database = {
          type = "postgres";
          user = "grafana";
          host = "/run/postgresql";
          name = "grafana";
          password = "";
        };
      };

      provision = {
        enable = true;

        datasources.settings = {
          datasources = [
            (mkDatasource "prometheus" "http://localhost:9090" {})
            (mkDatasource "loki" "http://localhost:33100" {})
          ];
        };

        dashboards.settings = {
          providers = [
            {
              options = {
                path = ./dashboards;
                foldersFromFilesStructure = true;
              };
            }
          ];
        };
      };
    };

    services.postgresql = {
      ensureDatabases = ["grafana"];
      ensureUsers = [
        {
          name = "grafana";
          ensurePermissions."DATABASE grafana" = "ALL PRIVILEGES";
        }
      ];
    };

    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      useACMEHost = "nixalted.com";

      locations = {
        "/" = {
          #proxyPass = "http://localhost:${grafanaPort}";
          #proxyWebsockets = true;

          extraConfig = ''
            auth_request /auth;
            auth_request_set $auth_user $upstream_http_tailscale_user;
            auth_request_set $auth_name $upstream_http_tailscale_name;
            auth_request_set $auth_login $upstream_http_tailscale_login;
            auth_request_set $auth_tailnet $upstream_http_tailscale_tailnet;
            auth_request_set $auth_profile_picture $upstream_http_tailscale_profile_picture;

            proxy_set_header X-Webauth-User "$auth_user";
            proxy_set_header X-Webauth-Name "$auth_name";
            proxy_set_header X-Webauth-Login "$auth_login";
            proxy_set_header X-Webauth-Tailnet "$auth_tailnet";
            proxy_set_header X-Webauth-Profile-Picture "$auth_profile_picture";
            proxy_pass http://localhost:${grafanaPort};
          '';
        };

        "/auth" = {
          extraConfig = ''
            internal;

            proxy_pass http://unix:/run/tailscale/tailscale.nginx-auth.sock;
            proxy_pass_request_body off;

            proxy_set_header Host $host;
            proxy_set_header Remote-Addr $remote_addr;
            proxy_set_header Remote-Port $remote_port;
            proxy_set_header Original-URI $request_uri;
          '';
        };
      };

      extraConfig = ''
        allow 100.0.0.0/8;
        deny  all;
      '';
    };
  };
}
