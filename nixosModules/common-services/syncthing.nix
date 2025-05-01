{
  config,
  username,
  lib,
  pkgs,
  ...
}:
let
  syncthingEntries = {
    blackberry = "S3S7WIB-2J2YK4E-VIKFG4K-FZ7N4OI-43RXU3D-T5FX3AD-PQCJPSX-LNQNRA5";
    blueberry = "SL3S7GW-EQEX37K-3COOIHY-BBWOIUH-TALXXCN-B4IQOOD-E5STX5U-IKU2HAX";
    cloudberry = "PTFQGBZ-ZJ7PPKR-EDO2NOZ-IHFWCY6-AO7CW3X-G7VVFBH-R7IEE6G-Y2KK3QJ";
    google-pixel-4a = "74LQXWB-GVD5FVU-7CYZUFK-MNIIYA4-X3ZJCHR-VQM7UM7-HBNL4VM-PUNYTAW";
  };
  syncthingHostsHighStorage = [
    "blackberry"
    "blueberry"
  ];
  syncthingHostsList = syncthingHostsHighStorage ++ [ "cloudberry" ];
  syncthingStorageAndPhone = syncthingHostsHighStorage ++ [ "google-pixel-4a" ];

  syncthingDevicesConfig = lib.mapAttrs (n: v: {
    addresses = [
      "tcp://${n}"
      "quic://${n}"
    ];
    id = v;
  }) syncthingEntries;

  clear-phone-photos = pkgs.writeScript "clear-phone-photos" (
    builtins.readFile ./clear-phone-photos.nu
  );

  hostname = config.networking.hostName;

  allFolders = {
    ".config/newsboat" = {
      path = "/home/${username}/.config/newsboat";
      devices = syncthingHostsList;
      versioning = {
        type = "trashcan";
        params.cleanoutDays = "30";
      };
    };
    "LEFilters" = {
      path = "/home/${username}/.local/share/Steam/steamapps/compatdata/899770/pfx/drive_c/users/steamuser/AppData/LocalLow/Eleventh\ Hour\ Games/Last\ Epoch/Filters";
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
      devices = syncthingStorageAndPhone;
      versioning = {
        type = "trashcan";
        params.cleanoutDays = "30";
      };
    };
    "Photos" = {
      path = "/home/${username}/Pictures/Photos";
      devices = syncthingHostsHighStorage;
    };
    "Photos-phone" = {
      path = "/home/${username}/Pictures/Photos-phone";
      devices = syncthingStorageAndPhone;
      type = "receiveonly";
    };
  };

  folders = lib.filterAttrs (_: val: lib.any (device: device == hostname) val.devices) allFolders;

in
{
  hm = lib.mkMerge [
    {
      xdg.userDirs.extraConfig = {
        XDG_SYNC_DIR = "$HOME/Sync";
      };
    }
    (lib.mkIf (hostname != "cloudberry") {
      systemd.user.services."mirror-phone-photos" = {
        Unit.Description = "Mirror photos that were synced from phone to the general photo folder";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.rsync}/bin/rsync -azvhPc --exclude='.stfolder' --mkpath Photos-phone/ Photos";
          ExecStartPost = "${pkgs.nushell}/bin/nu ${clear-phone-photos}";
          WorkingDirectory = "/home/${username}/Pictures";
        };
      };
      systemd.user.timers."mirror-phone-photos" = {
        Unit.Description = "Mirror photos that were synced from phone to the general photo folder";
        Timer = {
          OnCalendar = "hourly";
          Unit = "mirror-phone-photos.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    })
  ];

  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    user = "${username}";
    dataDir = "/home/${username}";
    settings = {
      devices = syncthingDevicesConfig;
      inherit folders;
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
