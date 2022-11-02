{
  username,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./alacritty.nix
    ./mpv.nix
    ./zathura.nix
  ];

  config.home-manager.users."${username}" = {config, ...}: {
    home = {
      packages = with pkgs; [
        ungoogled-chromium
        freetube
        tdesktop
        keepassxc
        discord
        qbittorrent
        element-desktop-wayland
        cinnamon.nemo
        obsidian
        easyeffects
        xdg-utils
        wireshark
        anydesk
      ];
    };

    programs = {
      obs-studio.enable = true;
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        theme = "purple";
        terminal = "alacritty";
      };
    };

    services.udiskie.enable = true;
    services.mpd = {
      enable = true;
      network.startWhenNeeded = true;
      dataDir = "${config.home.homeDirectory}/.config/mpd";
      musicDirectory = "${config.home.homeDirectory}/Music";
      extraConfig = ''
        audio_output {
            type "pipewire"
            name "Pipewire"
          }
      '';
    };
  };
}
