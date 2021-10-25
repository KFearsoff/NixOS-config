{ lib, pkgs, inputs, system, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, ... }:

let
  neovim = inputs.neovim.packages.${system}.neovim;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.user = {
      home = {
        packages = with pkgs; [
            libreoffice
            alacritty 
            gnumake cachix unzip
            ungoogled-chromium freetube tdesktop
            obs-studio
            keepassxc
            obsidian
            discord
            dolphin
            dmenu
            swaylock
            swayidle
            wl-clipboard
            mako
            rofi
            gimp
            cmake
            bottom # htop alternative
            qbittorrent
            ripgrep # alternative to grep
            bat # alternative to cat
            delta # git and diff viewer
            du-dust # alternative to du
            duf # alternative to df
            fd # alternative to find
            nix-prefetch-github
            gh
            zathura
          ];
      
        keyboard = {
          layout = "us,ru";
          options = [ "grp:alt_shift_toggle" "caps:swapescape" ];
        };
      };
      
      programs = {
        alacritty = {
          enable = true;
        };
      
        zsh = import ../../desktop/zsh.nix {
          inherit lib pkgs zsh-autosuggestions zsh-you-should-use zsh-history-substring-search zsh-nix-shell;
        };
      
        neovim = {
          enable = true;
          package = neovim;
          viAlias = true;
          vimAlias = true;
      
          plugins = with pkgs.vimPlugins; [
            vim-nix
          ];
        };
      
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv = {
            enable = true;
            enableFlakes = true;
          };
        };

        rofi = {
          enable = true;
          theme = "sidebar";
          terminal = "alacritty";      
        };
      };
      
      services = {
        flameshot.enable = true;
      };

      wayland.windowManager.sway = import ../../desktop/sway.nix { inherit lib pkgs; };
      
      gtk = import ../../desktop/gtk.nix { inherit pkgs; };
      qt = {
        enable = true;
        platformTheme = "gtk";
      };
    };
  };
}
