{ lib, pkgs, inputs, system, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, nix-colors, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.user = rec {
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
          ];
        };
        
      imports = [ nix-colors.homeManagerModule ];

      colorscheme = nix-colors.colorSchemes.dracula;
      
      programs = {
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
                cursor = "0x${colorscheme.colors.base05}";
              };

              normal = {
                black = "0x${colorscheme.colors.base00}";
                red = "0x${colorscheme.colors.base08}";
                green = "0x${colorscheme.colors.base0B}";
                yellow = "0x${colorscheme.colors.base0A}";
                blue = "0x${colorscheme.colors.base0D}";
                magenta = "0x${colorscheme.colors.base0E}";
                cyan = "0x${colorscheme.colors.base0C}";
                white = "0x${colorscheme.colors.base05}";
              };

              bright = {
                black = "0x${colorscheme.colors.base03}";
                red = "0x${colorscheme.colors.base09}";
                green = "0x${colorscheme.colors.base01}";
                yellow = "0x${colorscheme.colors.base02}";
                blue = "0x${colorscheme.colors.base04}";
                magenta = "0x${colorscheme.colors.base06}";
                cyan = "0x${colorscheme.colors.base0F}";
                white = "0x${colorscheme.colors.base07}";
              };

              draw_bold_test_with_bright_colors = false;
            };

            font.size = 14.0;
            background_opacity = 0.85;
          };
        };
        
        waybar.enable = true;

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
          package = pkgs.neovim-nightly;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
      
          plugins = with pkgs.vimPlugins; [
	  vim-airline
	  vim-nix
            dracula-vim
            nvim-lspconfig 
            nvim-cmp
          ];

          extraConfig = ''
            set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
            set clipboard+=unnamedplus
            syntax enable
            colorscheme dracula

	    lua << EOF
	    require'lspconfig'.rnix.setup{}
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

      wayland.windowManager.sway = import ../modules/sway { inherit lib pkgs colorscheme; };

      services.udiskie.enable = true;
      
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
