{
  config,
  lib,
  pkgs,
  username,
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
  ];

  options.nixchad.gui = {
    enable = mkEnableOption "gui programs";
    obs = mkEnableOption "obs";
    rofi = mkEnableOption "rofi";
  };

  config = mkIf cfg.enable {
    nixchad.gui.obs = mkDefault true;
    nixchad.gui.rofi = mkDefault true;

    environment.systemPackages = with pkgs; [
      xdg-utils
    ];

    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        ungoogled-chromium
        freetube
        tdesktop
        keepassxc
        qbittorrent
        element-desktop-wayland
        cinnamon.nemo
        obsidian
      ]
      ++ (optional config.services.pipewire.enable easyeffects)
      ++ (optional config.programs.wireshark.enable wireshark);

      services.udiskie.enable = true;
      programs = {
        obs-studio.enable = cfg.obs;
        rofi = {
          enable = cfg.rofi;
          package = pkgs.rofi-wayland;
          theme = "purple";
          terminal = "alacritty";
        };
      };
    };
  };
}
