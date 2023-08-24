{
  hm = {
    services.kanshi = {
      enable = true;
      profiles = {
        home = {
          outputs = [
            {
              criteria = "DP-1";
              status = "enable";
              position = "0,0";
              adaptiveSync = true;
            }
          ];
        };
      };
    };
  };
}
