{ username, config, pkgs, lib, ... }:

{
  config.home-manager.users."${username}" = {
    home = {
      packages = with pkgs; [
        neofetch
        vlc
        anydesk
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
        swaylock
        swayidle
        wl-clipboard
        mako
        gimp
        cmake
        bottom # htop alternative
        qbittorrent
        ripgrep # alternative to grep
        bat # alternative to cat
        du-dust # alternative to du
        duf # alternative to df
        fd # alternative to find
        exa # alternative to ls
        tokei # list used programming languages
        procs # alternative to ps
        nix-prefetch-github
        gh
        zathura
        feh
        statix
        rnix-lsp
        ansible
        udiskie
        shellcheck
        element-desktop-wayland
        sway-contrib.grimshot
        nixpkgs-fmt
      ];
    };

    programs = {
      waybar = {
        enable = true;
        systemd.enable = true;
        systemd.target = "sway-session.target";
      };

      git = {
        enable = true;
        delta.enable = true;
      };

      obs-studio.enable = true;

       neovim = import ./neovim.nix { inherit pkgs; };

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      rofi = {
        enable = true;
        package = pkgs.nur.repos.kira-bruneau.rofi-wayland;
        theme = "siderbar";
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
