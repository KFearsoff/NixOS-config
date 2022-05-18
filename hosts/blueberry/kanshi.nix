{
  config,
  username,
  ...
}: {
  config.home-manager.users."${username}" = {
    services.kanshi = {
      enable = true;
      profiles = {
        unplugged = {
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,0";
              mode = "2240x1400@60Hz";
              scale = 1.5;
            }
          ];
        };
        plugged = {
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              position = "0,1440";
              mode = "2240x1400@60Hz";
              scale = 1.5;
            }
            {
              criteria = "HDMI-A-1";
              status = "enable";
              position = "0,0";
              mode = "2560x1440@60Hz";
            }
          ];
        };
      };
    };
  };
}
