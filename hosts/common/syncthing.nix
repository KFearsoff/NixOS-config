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
    XDG_PROJ_DIR = "$HOME/Projects";
  };

  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    user = "${username}";
    dataDir = "/home/${username}";
    devices = (import ../default.nix { inherit lib; }).syncthingDevicesConfig;
    folders =
      {
        ".config/newsboat" = {
          path = "/home/${username}/.config/newsboat";
          devices = (import ../default.nix { inherit lib; }).syncthingHostsList;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Sync" = {
          path = "/home/${username}/Sync";
          devices = (import ../default.nix { inherit lib; }).syncthingHostsList;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Projects" = {
          path = "/home/${username}/Projects";
          devices = (import ../default.nix { inherit lib; }).syncthingHostsList;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Notes" = {
          path = "/home/${username}/Documents/Notes";
          devices = ["blueberry" "blackberry" "pixel-4a" "virtberry"];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
      }
      // (
        if (hostname != "virtberry")
        then {
          "Photos" = {
            path = "/home/${username}/Pictures/Photos";
            devices = lib.remove "virtberry" (import ../default.nix { inherit lib; }).syncthingHostsList;
          };
          "Photos-phone" = {
            path = "/home/${username}/Pictures/Photos-phone";
            devices = ["blueberry" "blackberry" "pixel-4a"];
            type = "receiveonly";
            versioning = {
              type = "trashcan";
              fsPath = "/home/${username}/Pictures/Photos";
              params.cleanoutDays = "0";
            };
          };
        }
        else {}
      );
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
