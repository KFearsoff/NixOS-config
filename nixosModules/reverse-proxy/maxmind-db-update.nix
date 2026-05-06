{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixchad.maxmind-db-update;
in
{
  options = {
    nixchad.maxmind-db-update = lib.mkOption {
      default = { };
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "maxmind-db-update";
            attachTo = lib.mkOption {
              type = lib.types.str;
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.timers."maxmind-db-update" = {
      enable = true;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Persistent = true;
        OnCalendar = "weekly";
        Unit = "maxmind-db-update.service";
      };
    };

    systemd.services."maxmind-db-update" = {
      wants = [ "network.target" ];
      path = [
        pkgs.curl
        pkgs.gnutar
        pkgs.gzip
      ];
      script =
        let
          url = "https://download.maxmind.com/geoip/databases/GeoLite2-ASN/download?suffix=tar.gz";
        in
        ''
          cd /var/lib/${config.systemd.services.${cfg.attachTo}.serviceConfig.StateDirectory}
          curl --fail "${url}" -L -K ''${CREDENTIALS_DIRECTORY}/maxmind-credentials -s \
            | tar --strip-components 1 -xzf - --wildcards '*/GeoLite2-ASN.mmdb'
        '';
      serviceConfig =
        let
          attachedConfig = config.systemd.services.${cfg.attachTo}.serviceConfig;
        in
        {
          Type = "oneshot";
          DynamicUser = true;
          User = lib.attrByPath [ "User" ] cfg.attachTo attachedConfig;
          Restart = "on-failure";
          UMask = "0077";

          LoadCredential = [ "maxmind-credentials:/secrets/maxmind-credentials" ];

          inherit (attachedConfig) StateDirectory;

          ProtectSystem = "strict";
          ProtectClock = true;
          ProtectHostname = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          ProtectControlGroups = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectKernelLogs = true;
          ProtectHome = true;

          PrivateTmp = true;
          PrivateDevices = true;
          PrivateUsers = true;

          SystemCallArchitectures = "native";
          DevicePolicy = "closed";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];
          CapabilityBoundingSet = [ "" ];
        };
    };
  };
}
