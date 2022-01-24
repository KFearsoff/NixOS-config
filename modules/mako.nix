{ config, username, ... }:

let inherit (config.home-manager.users."${username}") colorscheme; in
{
  config.home-manager.users."${username}" = {
    programs.mako = {
      enable = true;

      backgroundColor = "#${colorscheme.colors.base00}";
      textColor = "#${colorscheme.colors.base05}";
      borderColor = "#${colorscheme.colors.base0D}";

      extraConfig = ''
        [urgency=low]
        background-color=#${colorscheme.colors.base00}
        text-color=#${colorscheme.colors.base0A}
        border-color=#${colorscheme.colors.base0D}

        [urgency=high]
        background-color=#${colorscheme.colors.base00}
        text-color=#${colorscheme.colors.base08}
        border-color=#${colorscheme.colors.base0D}
      '';

      defaultTimeout = 5000; # ms
      ignoreTimeout = true;

    };
  };
}
