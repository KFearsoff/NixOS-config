{username, ...}: {
  config.home-manager.users."${username}" = {
    programs.git = {
      enable = true;
      extraConfig = {
        merge = {
          conflictStyle = "diff3";
        };
        diff = {
          colorMoved = "default";
          sopsdiffer.textconv = "sops -d";
        };
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "base16";
          # side-by-side = true;
        };
      };
    };
  };
}
