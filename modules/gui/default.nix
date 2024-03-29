{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.gui;
in {
  imports = [
    ./alacritty.nix
    ./kitty.nix
    ./mpv.nix
    ./zathura.nix
    ./office.nix
    ./graphics.nix
    ./vscodium.nix
    ./newsboat.nix
    ./pipewire.nix
    ./theming.nix
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
      home.packages = with pkgs;
        [
          freetube
          tdesktop
          qbittorrent
          element-desktop
          slack
          discord
          ardour
          lingot
          cinnamon.nemo
          remmina
          pinta
        ]
        #++ (optional config.services.pipewire.enable easyeffects)
        ++ (optional config.programs.wireshark.enable wireshark)
        ++ (optional (!config.nixchad.firefox.enable) ungoogled-chromium);

      services = {
        udiskie.enable = true;
        safeeyes.enable = true;
        caffeine.enable = true;
      };

      programs = {
        noti.enable = true;
        obs-studio.enable = cfg.obs;
        rofi = {
          enable = cfg.rofi;
          package = pkgs.rofi-wayland;
          theme = "purple";
          terminal = "alacritty";
          extraConfig = {
            show-icons = true;
          };
        };
      };
    };
  };
}
