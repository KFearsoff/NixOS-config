{ lib, pkgs, inputs, system, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.user = {
      home = {
        packages = with pkgs; [
            libreoffice
            gnumake cachix unzip
            ungoogled-chromium freetube tdesktop
            keepassxc
            obsidian
            discord
            dolphin
            dmenu
            swaylock
            swayidle
            waybar
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
            nix-prefetch-github
            gh
            zathura
            grim
            slurp
            feh
            statix
	    rnix-lsp
            nodejs-12_x # required for rnix-lsp
            ansible
            udiskie
          ];
      };
      
      programs = {
        alacritty = {
          enable = true;
          settings = {
            font.size = 14.0;
            background_opacity = 0.85;
          };
        };

        git = {
          enable = true;
          delta.enable = true;
        };

        obs-studio.enable = true;
      
        zsh = import ../modules/zsh.nix {
          inherit lib pkgs zsh-autosuggestions zsh-you-should-use zsh-history-substring-search zsh-nix-shell;
        };
      
        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          coc = {
            enable = true;
            settings = {
              languageserver = {
                nix = {
                  command = "rnix-lsp";
                  filetypes = [ "nix" ];
                };
              };
            };
          };
      
          plugins = with pkgs.vimPlugins; [
            dracula-vim
	    coc-nvim
            vim-nix
          ];

          extraConfig = ''
            set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
            '';
        };
      
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };


        rofi = {
          enable = true;
          package = pkgs.nur.repos.kira-bruneau.rofi-wayland;
          theme = "sidebar";
          terminal = "alacritty";      
        };
      };

      services.udiskie.enable = true;
      
      wayland.windowManager.sway = import ../modules/sway { inherit lib pkgs; };
      
      gtk = import ../modules/gtk.nix { inherit pkgs; };
      home.sessionVariables = { 
        # don't remember, let it be for now
        DESKTOP_SESSION = "sway";
        SDL_VIDEODRIVER = "wayland";
        GTK_BACKEND = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
        XDG_SESSION_TYPE = "sway";
        # Nouveau fix
        WLR_DRM_NO_MODIFIERS = "1";
        # required for some Java apps to work on Wayland
        _JAWA_AWT_WM_NONREPARENTING = "1";
        # required for Qt apps to run properly
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_QPA_PLATFORM = "wayland-egl";

        EDITOR = "nvim";
      };
      qt = {
        enable = true;
        platformTheme = "gtk";
        style.name = "gtk2";
      };
    };
  };
}
