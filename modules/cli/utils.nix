{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.utils;
in {
  options.nixchad.utils = {
    enable = mkEnableOption "utils";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        neofetch # the system won't boot without it
        ripgrep # alternative to grep
        fd # alternative to find
        tldr
        nix-tree
        ncdu
      ]
      ++ optionals (config.nixchad.filesystem.enable && config.nixchad.filesystem.type == "btrfs") [
        btdu
      ]
      ++ optionals (config.nixchad.filesystem.enable && config.nixchad.filesystem.type == "ext4") [
        du-dust
        duf
      ];

    hm = {
      home = {
        packages = with pkgs; [
          bottom # htop alternative
          eza # alternative to ls
          tokei # list used programming languages
          procs # alternative to ps
          shellcheck
          ascii-image-converter
        ];
      };

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };
    };
  };
}
