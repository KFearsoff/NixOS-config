{username, ...}: {
  home-manager.users."${username}" = {
    services.gammastep = {
      enable = true;
      latitude = 55.7;
      longitude = 37.6;
    };
  };
}
