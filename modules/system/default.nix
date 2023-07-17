{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.system;
in {
  imports = [
    ./containers.nix
    ./fonts.nix
    ./libvirt.nix
    ./location.nix
    ./nixconf.nix
    ./impermanence.nix
    ./networking.nix
    ./boot.nix
    ./filesystem.nix
    ./colors.nix
    ./tty.nix
    ./minimal.nix
    ./hardware.nix
    ./ssh.nix
  ];

  options.nixchad.system = {
    enable = mkEnableOption "system";
  };

  config = mkIf cfg.enable {
    nixchad = {
      impermanence.enable = mkDefault true;
      networking.enable = mkDefault true;
      boot.enable = mkDefault true;
      filesystem.enable = mkDefault true;
      colors.enable = mkDefault true;
      hardware.enable = mkDefault true;
    };

    users.mutableUsers = false;

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    security.sudo.wheelNeedsPassword = lib.mkDefault false;
    users.users."${username}".openssh.authorizedKeys.keys = config.lib.metadata.sshPubkeyList;

    services.journald.extraConfig = "SystemMaxUse=100M";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = lib.mkDefault "23.05"; # Did you read the comment?
  };
}
