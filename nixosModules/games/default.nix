{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.games;
in
{
  imports = [
    ./league-of-legends.nix
    ./legends-of-runeterra.nix
  ];

  options.nixchad.games = {
    enable = mkEnableOption "games profile";
    poe.enable = mkEnableOption "Path of Exile tools";
    gamemode.enable = mkEnableOption "gamemode";
    lutris.enable = mkEnableOption "lutris";

    lutrisPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      defaultText = literalExpression "[]";
      description = ''
        Packages to add to Lutris
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

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
        packages =
          optional cfg.poe.enable pkgs.rusty-path-of-building
          ++ optional cfg.lutris.enable (pkgs.lutris.override { extraPkgs = _: cfg.lutrisPackages; });
      };

      programs.mangohud = {
        enable = true;
        enableSessionWide = true;
      };
    };
  };
}
