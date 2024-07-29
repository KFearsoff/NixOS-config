{
  hm = {
    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "unplugged";
          profile.outputs = [
            {
              criteria = "eDP-2";
              status = "enable";
              position = "0,0";
              mode = "1920x1080@165";
              adaptiveSync = true;
            }
          ];
        }
        {
          profile.name = "plugged";
          profile.outputs = [
            {
              criteria = "eDP-2";
              status = "enable";
              position = "0,0";
              mode = "1920x1080@165";
              adaptiveSync = true;
            }
            {
              criteria = "HDMI-A-1";
              status = "enable";
              position = "0,-1440";
              adaptiveSync = true;
            }
          ];
        }
      ];
    };
  };
}
