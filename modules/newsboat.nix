{ pkgs, username, ... }:

{
  config.home-manager.users."${username}" = {
    programs.newsboat = {
      enable = true;
      autoReload = true;
      declarativeUrls = false;
      extraConfig = ''
        color background         default default
        color listnormal         default default
        color listnormal_unread  color15 default bold
        color listfocus          green   default reverse
        color listfocus_unread   color10 default reverse bold
        color title              cyan    default reverse
        color info               magenta default reverse
        color hint-description   magenta default
        color article            default default
        color end-of-text-marker color8  default

        # Highlight URLs with regex
        highlight article "[a-z]+://[^ ]+" green default underline

        bind-key j down
        bind-key k up
        bind-key h quit
        bind-key l open
      '';
    };

    systemd.user.services.newsboat-update = {
      Unit = { Description = "Update Newsboat feeds"; };
      Service = { ExecStart = "${pkgs.newsboat}/bin/newsboat -x reload"; };
    };

    systemd.user.timers.newsboat-update = {
      Unit = { Description = "Update Newsboat feeds"; };
      Timer = {
        OnCalendar = "hourly";
        Unit = "newsboat-update.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
