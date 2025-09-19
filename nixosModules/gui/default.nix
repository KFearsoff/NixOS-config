{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.gui;
in
{
  imports = [
    ./alacritty.nix
    ./mpv.nix
    ./zathura.nix
    ./office.nix
    ./graphics.nix
    ./newsboat.nix
    ./pipewire.nix
    ./firefox.nix
    ./mpd.nix
  ];

  options.nixchad.gui = {
    enable = mkEnableOption "gui programs";
    obs = mkEnableOption "obs";
    rofi = mkEnableOption "rofi";
  };

  config = mkIf cfg.enable {
    nixchad = {
      gui = {
        obs = mkDefault false;
        rofi = mkDefault true;
        pipewire = mkDefault true;
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-utils
    ];

    services.gvfs.enable = true;

    hm = {
      home.packages =
        with pkgs;
        [
          freetube
          telegram-desktop
          qbittorrent
          element-desktop
          slack
          discord
          # ardour
          # lingot
          nemo
          # pinta
          chromium
        ]
        #++ (optional config.services.pipewire.enable easyeffects)
        ++ (optional config.programs.wireshark.enable wireshark)
        ++ (optional (!config.nixchad.firefox.enable) ungoogled-chromium);

      services = {
        udiskie.enable = true;
        safeeyes.enable = false;
        caffeine.enable = false;
      };

      programs = {
        noti.enable = true;
        obs-studio.enable = cfg.obs;
        rofi = {
          enable = cfg.rofi;
          terminal = "alacritty";
          extraConfig = {
            show-icons = true;
          };
        };
      };
    };
  };
}
