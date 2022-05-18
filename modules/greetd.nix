{username, ...}: {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "$SHELL -l";
        user = "${username}";
      };
      default_session = initial_session;
    };
  };
}
