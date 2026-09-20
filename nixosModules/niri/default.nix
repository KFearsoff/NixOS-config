{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixchad.niri;
  inherit (lib) mkEnableOption mkIf;
in
{
  imports = [
    ./greetd.nix
    ./mako.nix
    ./waybar.nix
  ];

  options.nixchad.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    programs.niri.enable = true;
    environment.systemPackages = [
      pkgs.xwayland-satellite
    ];
    systemd.user.services.niri.wants = [ "mako.service" ];

    hm = {
      home.packages = [
        pkgs.wl-clipboard
        pkgs.grim
        pkgs.brightnessctl
      ];

      services.flameshot = {
        enable = true;
      };

      xdg.autostart.entries = [
        "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
        "${pkgs.freetube}/share/applications/freetube.desktop"
        "${pkgs.element-desktop}/share/applications/element-desktop.desktop"
        "${pkgs.slack}/share/applications/slack.desktop"
        "${pkgs.firefox}/share/applications/firefox.desktop"
        "${pkgs.zulip}/share/applications/zulip.desktop"
        "${pkgs.discord}/share/applications/discord.desktop"
        "${pkgs.obsidian}/share/applications/obsidian.desktop"
        "${pkgs.steam}/share/applications/steam.desktop"
      ];
    };
  };
}
