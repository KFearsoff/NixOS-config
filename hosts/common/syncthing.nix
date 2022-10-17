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
    devices = {
      "blueberry" = {
        id = "O3BLXFF-YZDZXSU-MZMNFVX-WDQ2OZU-3UZ7SSK-4BEN6DU-COS4LM4-7MP6QAQ";
        addresses = ["tcp://blueberry" "quic://blueberry"];
      };
      "blackberry" = {
        id = "S3S7WIB-2J2YK4E-VIKFG4K-FZ7N4OI-43RXU3D-T5FX3AD-PQCJPSX-LNQNRA5";
        addresses = ["tcp://blackberry" "quic://blackberry"];
      };
      "pixel-4a" = {
        id = "74LQXWB-GVD5FVU-7CYZUFK-MNIIYA4-X3ZJCHR-VQM7UM7-HBNL4VM-PUNYTAW";
        addresses = ["tcp://pixel-4a" "quic://pixel-4a"];
      };
      "virtberry" = {
        id = "LIT3MIA-VEPVHWZ-SC4Z76E-V5YFUV7-IF4TKR2-VOVI3E5-BKXIHFB-TYQE3QH";
        addresses = ["tcp://virtberry" "quic://virtberry"];
      };
    };
    folders =
      {
        ".config/newsboat" = {
          path = "/home/${username}/.config/newsboat";
          devices = ["blueberry" "blackberry" "virtberry"];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Sync" = {
          path = "/home/${username}/Sync";
          devices = ["blueberry" "blackberry" "virtberry"];
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        "Projects" = {
          path = "/home/${username}/Projects";
          devices = ["blueberry" "blackberry" "virtberry"];
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
            devices = ["blueberry" "blackberry"];
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
