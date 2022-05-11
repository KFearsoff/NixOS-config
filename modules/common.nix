{ username, config, pkgs, ... }:

{
  config.home-manager.users."${username}" = { config, ... }: {
    home = {
      packages = with pkgs; [
        neofetch
        virt-manager
        libreoffice
        gnumake
        unzip
        ungoogled-chromium
        freetube
        tdesktop
        keepassxc
        discord
        ranger
        gimp
        htop
        bottom # htop alternative
        qbittorrent
        ripgrep # alternative to grep
        bat # alternative to cat
        fd # alternative to find
        exa # alternative to ls
        tokei # list used programming languages
        procs # alternative to ps
        nix-prefetch-github
        statix
        udiskie
        shellcheck
        element-desktop-wayland
        nixpkgs-fmt
        tldr
        ascii-image-converter
        rnix-lsp
        tor-browser-bundle-bin
        wireguard-tools
        cinnamon.nemo
        obsidian
        easyeffects
        fzf
        du-dust
        duf
      ];
    };

    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

    systemd.user.startServices = "sd-switch";

    programs = {
      git = {
        enable = true;
        delta.enable = true;
      };

      obs-studio.enable = true;
      nix-index.enable = true;

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      rofi = {
        enable = true;
        package = pkgs.nur.repos.kira-bruneau.rofi-wayland;
        theme = "purple";
        terminal = "alacritty";
      };
    };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };

    services.udiskie.enable = true;
    services.swayidle = import ../modules/sway/swayidle.nix;
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

    gtk = import ../modules/gtk.nix { inherit pkgs; };
    home.sessionVariables = {
      EDITOR = "nvim";
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "gtk2";
    };
  };
}
