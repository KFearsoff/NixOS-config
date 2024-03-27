{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.mako;
  inherit (config.hm) colorScheme;
in {
  options.nixchad.mako = {
    enable = mkEnableOption "mako";
  };

  config = mkIf cfg.enable {
    hm = {
      services.mako = {
        enable = true;

        backgroundColor = "#${colorScheme.palette.base00}";
        textColor = "#${colorScheme.palette.base05}";
        borderColor = "#${colorScheme.palette.base0D}";

        extraConfig = ''
          [urgency=low]
          background-color=#${colorScheme.palette.base00}
          text-color=#${colorScheme.palette.base0A}
          border-color=#${colorScheme.palette.base0D}

          [urgency=high]
          background-color=#${colorScheme.palette.base00}
          text-color=#${colorScheme.palette.base08}
          border-color=#${colorScheme.palette.base0D}
        '';

        defaultTimeout = 5000; # ms
        ignoreTimeout = true;
      };
    };
  };
}
