{ config, username, ... }:

{
  config.home-manager.users."${username}" = {
        services.kanshi = {
        enable = true;
        profiles = {
          home = {
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
        };
      };
    };
}
