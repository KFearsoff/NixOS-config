{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.games;
in {
  imports = [
    ./league-of-legends.nix
    ./legends-of-runeterra.nix
  ];

  options.nixchad.games = {
    enable = mkEnableOption "games profile";
    gamemode.enable = mkEnableOption "gamemode";

    lutrisPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      defaultText = literalExpression "[]";
      description = ''
        Packages to add to Lutris
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;

    programs.gamemode = mkIf cfg.gamemode.enable {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };

        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    hm = {
      home = {
        packages = [
          (pkgs.lutris.override {extraPkgs = _: cfg.lutrisPackages;})
        ];
      };

      programs.mangohud = {
        enable = true;
        enableSessionWide = true;
      };
    };
  };
}
