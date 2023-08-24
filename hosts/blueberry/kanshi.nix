{
  hm = {
    services.kanshi = {
      enable = true;
      profiles = {
        home = {
          outputs = [
            {
              criteria = "eDP-2";
              status = "enable";
              position = "0,0";
              mode = "1920x1080@165";
              adaptiveSync = true;
            }
          ];
        };
      };
    };
  };
}
