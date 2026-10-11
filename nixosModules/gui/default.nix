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
    ./music.nix
    ./zathura.nix
    ./office.nix
    ./graphics.nix
    ./newsboat.nix
    ./pipewire.nix
    ./firefox.nix
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
    services.oo7.enable = true;

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
          nautilus
          zulip
          obsidian
          syncplay
          electrum
          anki
        ]
        #++ (optional config.services.pipewire.enable easyeffects)
        ++ (optional config.programs.wireshark.enable wireshark);

      services = {
        udiskie.enable = true;
      };

      programs = {
        noti.enable = true;
        obs-studio.enable = cfg.obs;
        rofi = {
          enable = cfg.rofi;
          settings = {
            terminal = "alacritty";
            show-icons = true;
          };
        };
      };
    };
  };
}
