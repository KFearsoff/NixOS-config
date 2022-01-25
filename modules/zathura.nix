{ config, username, pkgs, ... }:

let inherit (config.home-manager.users."${username}") colorscheme; in
{
  config.home-manager.users."${username}" = {
    programs.zathura = {
      enable = true;
      #package = pkgs.zathura.override { useMupdf = false; }; # https://git.pwmt.org/pwmt/zathura/-/issues/184
      options = {
        adjust-open = "best-fit";
        pages-per-row = 1;

        scroll-page-aware = true;
        scroll-full-overlap = "0.01";
        scroll-step = 50;

        zoom-min = 10;
        guioptions = "";



        default-bg = "#${colorscheme.colors.base00}";
        default-fg = "#${colorscheme.colors.base01}";

        statusbar-bg = "#${colorscheme.colors.base02}";
        statusbar-fg = "#${colorscheme.colors.base04}";

        inputbar-bg = "#${colorscheme.colors.base00}";
        inputbar-fg = "#${colorscheme.colors.base07}";

        notification-bg = "#${colorscheme.colors.base00}";
        notification-fg = "#${colorscheme.colors.base07}";

        notification-error-bg = "#${colorscheme.colors.base00}";
        notification-error-fg = "#${colorscheme.colors.base08}";

        notification-warning-bg = "#${colorscheme.colors.base00}";
        notification-warning-fg = "#${colorscheme.colors.base08}";

        highlight-color = "#${colorscheme.colors.base0A}";
        highlight-active-color = "#${colorscheme.colors.base0D}";

        completion-bg = "#${colorscheme.colors.base01}";
        completion-fg = "#${colorscheme.colors.base0D}";

        completion-highlight-bg = "#${colorscheme.colors.base0D}";
        completion-highlight-fg = "#${colorscheme.colors.base07}";

        recolor = true;
        recolor-lightcolor = "#${colorscheme.colors.base00}";
        recolor-darkcolor = "#${colorscheme.colors.base06}";
        recolor-reverse-video = true;
        recolor-keephue = true;

        render-loading = false;
      };
      extraConfig = ''
        unmap f
        map f toggle_fullscreen
        map [fullscreen] f toggle_fullscreen
      '';
    };
  };
}
