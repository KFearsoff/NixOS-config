{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.nixchad.newsboat;
in {
  options.nixchad.newsboat = {
    enable = mkEnableOption "newsboat";
  };

  config = mkIf cfg.enable {
    hm = {
      # https://github.com/nix-community/home-manager/issues/602
      disabledModules = [
        "programs/newsboat.nix"
      ];
      imports = [
        "${inputs.home-manager-newsboat}/modules/programs/newsboat.nix"
      ];

      home.shellAliases.newsboat = "newsboat -q";

      programs.newsboat = {
        enable = true;
        autoReload = true;
        browser = "\"${pkgs.xdg-utils}/bin/xdg-open &>/dev/null\""; # Don't write browser logs in stdin while in newsboat
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
        Unit = {Description = "Update Newsboat feeds";};
        Service = {ExecStart = "${pkgs.newsboat}/bin/newsboat -x reload";};
      };

      systemd.user.timers.newsboat-update = {
        Unit = {Description = "Update Newsboat feeds";};
        Timer = {
          OnCalendar = "hourly";
          Unit = "newsboat-update.service";
        };
        Install = {WantedBy = ["timers.target"];};
      };
    };
  };
}
