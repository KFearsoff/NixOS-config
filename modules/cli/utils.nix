{
  config,
  lib,
  pkgs,
  username,
  ...
}: with lib; let
  cfg = config.nixchad.utils;
in {
  options.nixchad.utils = {
    enable = mkEnableOption "utils";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      neofetch # the system won't boot without it
      ripgrep # alternative to grep
      fd # alternative to find
      tldr
      du-dust
      duf
      btdu
      jq
      nix-tree
      ncdu
    ];

    home-manager.users."${username}" = {
      home = {
        packages = with pkgs; [
          bottom # htop alternative
          exa # alternative to ls
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
