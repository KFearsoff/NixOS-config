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
        du-dust
        duf
        jq
        xdg-utils
        mullvad-vpn
        openconnect
        sops
      ];
    };

    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

    systemd.user.startServices = "sd-switch";

    programs = {
      fzf = {
        enable = true;
        defaultCommand = "fd --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
        defaultOptions = [ "--ansi" ];
        changeDirWidgetCommand = "fd --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
        changeDirWidgetOptions = [ "--layout=reverse" "--height=40%" "--ansi" "--select-1" "--exit-0" ];
        fileWidgetCommand = "fd --type f --follow --hidden --exclude .git --exclude .direnv --exclude lost+found --color=always";
        fileWidgetOptions = [ "--layout=reverse" "--height=40%" "--ansi" "--select-1" "--exit-0" ];
        historyWidgetOptions = [ "--ansi" "--exact" ];
      };
      bat = {
        enable = true;
        config = {
          theme = "base16";
          style = "plain";
        };
      };
      git = {
        enable = true;
        extraConfig = {
          merge = {
            conflictStyle = "diff3";
          };
          diff = {
            colorMoved = "default";
            sopsdiffer.textconv = "sops -d";
          };
        };
        delta = {
          enable = true;
          options = {
            navigate = true;
            line-numbers = true;
            syntax-theme = "base16";
            # side-by-side = true;
          };
        };
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
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "gtk2";
    };
  };
}
