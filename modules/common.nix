{ username, config, pkgs, lib, ... }:

{
  config.home-manager.users."${username}" = { lib, ... }: {
    home = {
      packages = with pkgs; [
        neofetch
        vlc
        docker-compose
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
        bottom # htop alternative
        qbittorrent
        ripgrep # alternative to grep
        bat # alternative to cat
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
        terraform-ls
        nodePackages.bash-language-server
        ansible
        udiskie
        shellcheck
        element-desktop-wayland
        sway-contrib.grimshot
        nixpkgs-fmt
        tldr
      ];
    };

    home.activation = {
      reloadKanshi = lib.hm.dag.entryAnywhere ''
        $DRY_RUN_CMD systemctl --user restart kanshi.service
      '';
      reloadWaybar = lib.hm.dag.entryAnywhere ''
        $DRY_RUN_CMD systemctl --user restart waybar.service
      '';
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
