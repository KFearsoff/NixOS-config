{
  username,
  pkgs,
  ...
}: {
  home-manager.users."${username}" = {
    programs.bat = {
      enable = true;
      config = {
        theme = "base16";
        style = "plain";
      };
    };
    home.sessionVariables = {
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    };
  };
}
