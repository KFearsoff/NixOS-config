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
  ];

  options.nixchad.system = {
    enable = mkEnableOption "system";
  };

  config = mkIf cfg.enable {
    users.mutableUsers = false;

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    security.sudo.wheelNeedsPassword = lib.mkDefault false;
    users.users."${username}".openssh.authorizedKeys.keys = config.lib.metadata.sshPubkeyList;

    sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
    sops.gnupg.sshKeyPaths = lib.mkForce [];
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = true;

    services.smartd.enable = true;
    services.smartd.defaults.monitored = "-a -o on -s (S/../01/./03|L/(01|07)/.././03)";
    services.fwupd.enable = true;
    services.gvfs.enable = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = lib.mkDefault "22.05"; # Did you read the comment?
  };
}
