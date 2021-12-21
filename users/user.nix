{ lib, pkgs, inputs, system, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, nix-colors, ... }:

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
            shellcheck
            element-desktop-wayland
          ];
        };

      imports = [ nix-colors.homeManagerModule ];

      colorscheme = nix-colors.colorSchemes.dracula;
      
      programs = let colorscheme = nix-colors.colorSchemes.dracula; in {
        alacritty = {
          enable = true;
          settings = {
            colors = {
              primary = {
                background = "0x${colorscheme.colors.base00}";
                foreground = "0x${colorscheme.colors.base05}";
              };

              cursor = {
                text = "0x${colorscheme.colors.base00}";
                cursor = "0x${colorscheme.colors.base00}";
              };

              normal = {
                black = "0x${colorscheme.colors.base00}";
                red = "0x${colorscheme.colors.base00}";
                green = "0x${colorscheme.colors.base00}";
                yellow = "0x${colorscheme.colors.base00}";
                blue = "0x${colorscheme.colors.base00}";
                magenta = "0x${colorscheme.colors.base00}";
                cyan = "0x${colorscheme.colors.base00}";
                white = "0x${colorscheme.colors.base00}";
              };

              bright = {
                black = "0x${colorscheme.colors.base00}";
                red = "0x${colorscheme.colors.base00}";
                green = "0x${colorscheme.colors.base00}";
                yellow = "0x${colorscheme.colors.base00}";
                blue = "0x${colorscheme.colors.base00}";
                magenta = "0x${colorscheme.colors.base00}";
                cyan = "0x${colorscheme.colors.base00}";
                white = "0x${colorscheme.colors.base00}";
              };

              draw_bold_test_with_bright_colors = false;
            };

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
            set clipboard+=unnamedplus
            syntax enable
            colorscheme dracula
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
