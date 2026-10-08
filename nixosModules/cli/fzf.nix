{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.fzf;
  fd = "${pkgs.fd}/bin/fd";
in
{
  options.nixchad.fzf = {
    enable = mkEnableOption "fzf";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.fzf = {
        enable = true;
        defaultCommand = "${fd} --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
        defaultOptions = [ "--ansi" ];
        changeDirWidget = {
          command = "${fd} --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
          options = [
            "--layout=reverse"
            "--height=40%"
            "--ansi"
            "--select-1"
            "--exit-0"
          ];
        };
        fileWidget = {
          command = "${fd} --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
          options = [
            "--layout=reverse"
            "--height=40%"
            "--ansi"
            "--select-1"
            "--exit-0"
          ];
        };
        historyWidget = {
          options = [
            "--ansi"
            "--exact"
          ];
        };
      };
    };
  };
}
