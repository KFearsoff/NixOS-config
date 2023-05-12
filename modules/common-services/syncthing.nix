{
  username,
  config,
  ...
}: {
  hm.xdg.userDirs.extraConfig = {
    XDG_SYNC_DIR = "$HOME/Sync";
  };

  environment.persistence."/persist".presets.services.syncthing = false;

  services.syncthing = with config.lib.metadata; {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    user = "${username}";
    dataDir = "/home/${username}";
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
    extraOptions = {
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
