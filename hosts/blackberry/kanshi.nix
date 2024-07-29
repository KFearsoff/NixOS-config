{
  hm = {
    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "DP-1";
              status = "enable";
              position = "0,0";
              adaptiveSync = true;
            }
          ];
        }
      ];
    };
  };
}
