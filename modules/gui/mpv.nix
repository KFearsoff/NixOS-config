{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.mpv;
in {
  options.nixchad.mpv = {
    enable = mkEnableOption "mpv";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.mpv = {
        enable = true;
        defaultProfiles = ["gpu-hq"];
        scripts = [pkgs.mpvScripts.uosc];
        config = {
          hwdec = "auto";
          ytdl-format = "bestvideo+bestaudio";
        };
      };
    };
  };
}
