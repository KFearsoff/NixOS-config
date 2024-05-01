{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.cli;
in {
  imports = [
    ./debug.nix
    ./utils.nix
    ./git.nix
    ./kubernetes.nix
    ./fzf.nix
    ./nix-index.nix
    ./cloud.nix
    ./helix.nix
  ];

  options.nixchad.cli = {
    enable = mkEnableOption "cli";
  };

  config = mkIf cfg.enable {
    nixchad = {
      debug.enable = mkDefault true;
      utils.enable = mkDefault true;
      git.enable = mkDefault true;
    };

    environment.systemPackages = with pkgs; [
      wget
      jq
      git
      terraform-mpl
      awscli2
      aws-vault
      terragrunt
    ];
  };
}
