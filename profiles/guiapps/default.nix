{
  username,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./kitty.nix
    ./mako.nix
    ./mpv.nix
    ./myteam.nix
    ./theming.nix
    ./vscodium.nix
    ./zathura.nix
  ];

  config.home-manager.users."${username}" = {config, ...}: {
    home = {
      packages = with pkgs; [
        virt-manager
        libreoffice
        ungoogled-chromium
        freetube
        tdesktop
        keepassxc
        discord
        ranger
        gimp
        qbittorrent
        udiskie
        element-desktop-wayland
        tor-browser-bundle-bin
        cinnamon.nemo
        obsidian
        easyeffects
        wireshark
      ];
    };

    programs = {
      obs-studio.enable = true;
      rofi = {
        enable = true;
        package = pkgs.nur.repos.kira-bruneau.rofi-wayland;
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
