{
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.nixchad.cli;
in {
  imports = [
    ./debug.nix
    ./utils.nix
    ./git.nix
    ./kubernetes.nix
    ./bat.nix
    ./fzf.nix
  ];

  options.nixchad.cli = {
    enable = mkEnableOption "cli";
  };

  config = mkIf cfg.enable {
    nixchad.debug.enable = mkDefault true;
    nixchad.utils.enable = mkDefault true;
    nixchad.git.enable = mkDefault true;
    nixchad.bat.enable = mkDefault true;

    environment.systemPackages = with pkgs; [
      wget
      jq
      git
    ];
  };
}
