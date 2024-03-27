{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.zathura;
  inherit (config.hm) colorScheme;
in {
  options.nixchad.zathura = {
    enable = mkEnableOption "zathura";
  };

  config = mkIf cfg.enable {
    hm = {
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

          default-bg = "#${colorScheme.palette.base00}";
          default-fg = "#${colorScheme.palette.base01}";

          statusbar-bg = "#${colorScheme.palette.base02}";
          statusbar-fg = "#${colorScheme.palette.base04}";

          inputbar-bg = "#${colorScheme.palette.base00}";
          inputbar-fg = "#${colorScheme.palette.base07}";

          notification-bg = "#${colorScheme.palette.base00}";
          notification-fg = "#${colorScheme.palette.base07}";

          notification-error-bg = "#${colorScheme.palette.base00}";
          notification-error-fg = "#${colorScheme.palette.base08}";

          notification-warning-bg = "#${colorScheme.palette.base00}";
          notification-warning-fg = "#${colorScheme.palette.base08}";

          highlight-color = "#${colorScheme.palette.base0A}";
          highlight-active-color = "#${colorScheme.palette.base0D}";

          completion-bg = "#${colorScheme.palette.base01}";
          completion-fg = "#${colorScheme.palette.base0D}";

          completion-highlight-bg = "#${colorScheme.palette.base0D}";
          completion-highlight-fg = "#${colorScheme.palette.base07}";

          # recoloring is bugged with mupdf:
          # https://git.pwmt.org/pwmt/zathura/-/issues/184
          # recolor = true;
          recolor-lightcolor = "#${colorScheme.palette.base00}";
          recolor-darkcolor = "#${colorScheme.palette.base06}";
          recolor-reverse-video = true;
          recolor-keephue = true;

          render-loading = false;
          selection-clipboard = "clipboard";
        };
        extraConfig = ''
          unmap f
          map f toggle_fullscreen
          map [fullscreen] f toggle_fullscreen
        '';
      };
    };
  };
}
