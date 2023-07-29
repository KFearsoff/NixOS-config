{
  username,
  lib,
  pkgs,
  ...
}: let
  syncthingEntries = {
    blackberry = "S3S7WIB-2J2YK4E-VIKFG4K-FZ7N4OI-43RXU3D-T5FX3AD-PQCJPSX-LNQNRA5";
    blueberry = "SL3S7GW-EQEX37K-3COOIHY-BBWOIUH-TALXXCN-B4IQOOD-E5STX5U-IKU2HAX";
    cloudberry = "PTFQGBZ-ZJ7PPKR-EDO2NOZ-IHFWCY6-AO7CW3X-G7VVFBH-R7IEE6G-Y2KK3QJ";
    pixel-4a = "74LQXWB-GVD5FVU-7CYZUFK-MNIIYA4-X3ZJCHR-VQM7UM7-HBNL4VM-PUNYTAW";
  };
  syncthingHostsList = ["blackberry" "blueberry" "cloudberry"];
  syncthingAllList = syncthingHostsList ++ ["pixel-4a"];

  syncthingDevicesConfig =
    lib.mapAttrs
    (n: v: {
      addresses = ["tcp://${n}" "quic://${n}"];
      id = v;
    })
    syncthingEntries;
in {
  hm = {
    xdg.userDirs.extraConfig = {
      XDG_SYNC_DIR = "$HOME/Sync";
    };

    systemd.user.services."mirror-phone-photos" = {
      Unit.Description = "Mirror photos that were synced from phone to the general photo folder";
      Service = {
        ExecStart = "${pkgs.rsync}/bin/rsync -azvhPc --mkpath Photos-phone/ Photos";
        WorkingDirectory = "/home/${username}/Pictures";
      };
    };

    systemd.user.timers."mirror-phone-photos" = {
      Unit.Description = "Mirror photos that were synced from phone to the general photo folder";
      Timer = {
        OnCalendar = "hourly";
        Unit = "mirror-phone-photos.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };

  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    user = "${username}";
    dataDir = "/home/${username}";
    settings = {
      devices = syncthingDevicesConfig;
      folders = {
        ".config/newsboat" = {
          path = "/home/${username}/.config/newsboat";
          devices = syncthingHostsList;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Sync" = {
          path = "/home/${username}/Sync";
          devices = syncthingHostsList;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Notes" = {
          path = "/home/${username}/Documents/Notes";
          devices = syncthingAllList;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Photos" = {
          path = "/home/${username}/Pictures/Photos";
          devices = syncthingHostsList;
        };
        "Photos-phone" = {
          path = "/home/${username}/Pictures/Photos-phone";
          # devices = syncthingOwnedList;
          devices = syncthingAllList;
          type = "receiveonly";
          versioning = {
            type = "trashcan";
            fsPath = "/home/${username}/Pictures/Photos";
            params.cleanoutDays = "0";
          };
        };
      };
      gui = {
        theme = "dark";
        insecureSkipHostcheck = true; # needed for reverse proxy
      };
      options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        urAccepted = -1;
        restartOnWakeup = true;
      };
    };
  };
}
