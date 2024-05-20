{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.zathura;
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

          # recoloring is bugged with mupdf:
          # https://git.pwmt.org/pwmt/zathura/-/issues/184
          # recolor = true;
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
