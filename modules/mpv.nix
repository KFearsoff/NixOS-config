{ username, pkgs, ... }:

{
  config.home-manager.users."${username}" = {
    programs.mpv = {
      enable = true;
      config = {
        profile = "gpu-hq";
        sub-auto = "fuzzy";
        sub-bold = "yes";
        hwdec = "auto-safe";
      };
    };
  };
}
