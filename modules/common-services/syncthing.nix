{
  username,
  inputs,
  config,
  lib,
  ...
}: let
  hostname = config.networking.hostName;
  syncthingHttpPort = "8384";
  syncthingDomain = "syncthing.${hostname}.box";
in {
  home-manager.users."${username}".xdg.userDirs.extraConfig = {
    XDG_SYNC_DIR = "$HOME/Sync";
  };

  services.syncthing = with (import ../../hosts { inherit lib;}); {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    user = "${username}";
    dataDir = "/home/${username}";
    devices = syncthingDevicesConfig;
    folders =
      {
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

  services.nginx.virtualHosts."${syncthingDomain}" = {
    forceSSL = true;
    sslCertificate = "/var/lib/self-signed/_.blackberry.box/cert.pem";
    sslCertificateKey = "/var/lib/self-signed/_.blackberry.box/key.pem";

    locations."/" = {
      proxyPass = "http://localhost:${syncthingHttpPort}";
      proxyWebsockets = true;
    };
  };
}