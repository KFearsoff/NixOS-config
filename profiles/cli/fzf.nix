{
  username,
  pkgs,
  ...
}: let
  fd = "${pkgs.fd}/bin/fd";
in {
  home-manager.users."${username}" = {
    programs.fzf = {
      enable = true;
      defaultCommand = "${fd} --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
      defaultOptions = ["--ansi"];
      changeDirWidgetCommand = "${fd} --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
      changeDirWidgetOptions = ["--layout=reverse" "--height=40%" "--ansi" "--select-1" "--exit-0"];
      fileWidgetCommand = "${fd} --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
      fileWidgetOptions = ["--layout=reverse" "--height=40%" "--ansi" "--select-1" "--exit-0"];
      historyWidgetOptions = ["--ansi" "--exact"];
    };
  };
}
