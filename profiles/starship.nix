{username, ...}: {
  config.home-manager.users."${username}" = {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$all";
        line_break = {
          disabled = true;
        };
      };
    };
  };
}
