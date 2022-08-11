{username, ...}: {
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
        addresses = ["tcp://100.66.71.32" "quic://100.66.71.32"];
      };
      "blackberry" = {
        id = "S3S7WIB-2J2YK4E-VIKFG4K-FZ7N4OI-43RXU3D-T5FX3AD-PQCJPSX-LNQNRA5";
        addresses = ["tcp://100.109.194.31" "quic://100.109.194.31"];
      };
      "pixel-4a" = {
        id = "74LQXWB-GVD5FVU-7CYZUFK-MNIIYA4-X3ZJCHR-VQM7UM7-HBNL4VM-PUNYTAW";
        addresses = ["tcp://100.107.161.19" "quic://100.107.161.19"];
      };
      "virtberry" = {
        id = "LIT3MIA-VEPVHWZ-SC4Z76E-V5YFUV7-IF4TKR2-VOVI3E5-BKXIHFB-TYQE3QH";
        addresses = ["tcp://100.94.96.106" "quic://100.94.96.106"];
      };
    };
    folders = {
      ".config/newsboat" = {
        path = "/home/${username}/.config/newsboat";
        devices = ["blueberry" "blackberry" "virtberry"];
      };
      "Sync" = {
        path = "/home/${username}/Sync";
        devices = ["blueberry" "blackberry" "virtberry"];
      };
      "Projects" = {
        path = "/home/${username}/Projects";
        devices = ["blueberry" "blackberry" "virtberry"];
      };
      "Notes" = {
        path = "/home/${username}/Documents/Notes";
        devices = ["blueberry" "blackberry" "pixel-4a" "virtberry"];
      };
      "Photos" = {
        path = "/home/${username}/Pictures/Photos";
        devices = ["blueberry" "blackberry" "pixel-4a"];
      };
    };
    extraOptions = {
      gui = {theme = "dark";};
      options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        urAccepted = -1;
        restartOnWakeup = true;
      };
    };
  };
}
