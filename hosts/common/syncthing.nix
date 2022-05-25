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
        addresses = ["tcp://192.168.1.183" "quic://192.168.1.183"];
      };
      "blackberry" = {
        id = "S3S7WIB-2J2YK4E-VIKFG4K-FZ7N4OI-43RXU3D-T5FX3AD-PQCJPSX-LNQNRA5";
        addresses = ["tcp://192.168.1.100" "quic://192.168.1.100"];
      };
    };
    folders = {
      ".config/newsboat" = {
        path = "/home/${username}/.config/newsboat";
        devices = ["blueberry" "blackberry"];
      };
      "Sync" = {
        path = "/home/${username}/Sync";
        devices = ["blueberry" "blackberry"];
      };
      "Projects" = {
        path = "/home/${username}/Projects";
        devices = ["blueberry" "blackberry"];
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
