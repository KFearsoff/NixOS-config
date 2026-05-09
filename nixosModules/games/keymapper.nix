{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    types
    ;
  cfg = config.nixchad.keymapper;
in
{
  options.nixchad.keymapper = {
    enable = mkEnableOption ''
      keymapper, A cross-platform context-aware key remapper.

      The program is split into two parts:
      - {command}`keymapperd` is the service which needs to be given the permissions to grab the keyboard devices and inject keys.
      - {command}`keymapper` should be run as normal user in a graphical environment. It loads the configuration, informs the service about it and the active context and also executes mapped terminal commands.
      This module only enables {command}`keymapperd`. You have to add {command}`keymapper` to the desktop environment's auto-started application.
    '';
    package = mkPackageOption pkgs "keymapper" { };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration lines to add.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."keymapper.conf".text = cfg.extraConfig;

    systemd.services.keymapperd = {
      description = "Keymapper daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${cfg.package}/bin/keymapperd -v";
        Restart = "always";
      };
    };
  };
}
