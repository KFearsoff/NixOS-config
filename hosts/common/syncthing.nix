{ pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    overrideDevices = true;
    overrideFolders = true;
    user = "nixchad";
    dataDir = "/home/nixchad";
    devices = {
      "blueberry" = { id = "O3BLXFF-YZDZXSU-MZMNFVX-WDQ2OZU-3UZ7SSK-4BEN6DU-COS4LM4-7MP6QAQ"; addresses = [ "tcp://192.168.1.183" "quic://192.168.1.183" ]; };
      "blackberry" = { id = "OY3H4IZ-SJPBWNM-YVYUE62-6E4EJ5U-TDCXKSC-FU2GTRU-7VXEXXH-6NMKDQI"; addresses = [ "tcp://192.168.1.100" "quic://192.168.1.100" ]; };
    };
    folders = {
      ".newsboat" = {
        path = "/home/nixchad/.newsboat";
        devices = [ "blueberry" "blackberry" ];
      };
      "Sync" = {
        path = "/home/nixchad/Sync";
        devices = [ "blueberry" "blackberry" ];
      };
    };
    extraOptions = {
      gui = { theme = "dark"; };
      options = {
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        urAccepted = -1;
        restartOnWakeup = true;
      };
    };
  };
}
