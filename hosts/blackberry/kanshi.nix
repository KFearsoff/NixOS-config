{ config, username, ... }:

{
  config.home-manager.users."${username}" = {
    services.kanshi = {
      enable = true;
      profiles = {
        home = {
          outputs = [
            {
              criteria = "HDMI-A-1";
              status = "enable";
              position = "0,0";
            }
          ];
        };
      };
    };
  };
}
