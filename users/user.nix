{ lib, pkgs, inputs, system, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, nix-colors, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = {
    users.users.user = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "docker" ];
      initialPassword = "test";
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.user = rec {
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

      imports = [ nix-colors.homeManagerModule ];

      colorscheme = nix-colors.colorSchemes.dracula;

      programs = {
        alacritty = import ../modules/alacritty.nix { inherit colorscheme; };
        waybar.enable = true;

        git = {
          enable = true;
          delta.enable = true;
        };

        obs-studio.enable = true;

        zsh = import ../modules/zsh.nix {
          inherit lib pkgs zsh-autosuggestions zsh-you-should-use zsh-history-substring-search zsh-nix-shell;
        };

        neovim = import ../modules/neovim.nix { inherit pkgs; };

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
