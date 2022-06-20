{
  lib,
  pkgs,
  username,
  ...
}: {
  users.mutableUsers = false;
  time.timeZone = lib.mkDefault "Europe/Moscow";
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot = {
    kernelParams = ["quiet" "udev.log_priority=3" "vt.global_cursor_default=0"];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  boot.cleanTmpDir = true;
  programs.fuse.userAllowOther = true;

  security.sudo.wheelNeedsPassword = lib.mkDefault false;
  security.sudo.extraConfig = ''
    Defaults lecture = never
    Defaults insults
  '';
  environment.etc."machine-id".source = "/persist/etc/machine-id";
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos" # persist UIDs and GIDs
      "/var/lib/systemd"
      "/etc/NetworkManager/system-connections"
    ];
  };

  users.users."${username}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKnUBxbvoSGs+Q+hhSUrwqNkVzmtnEc03Tt203PEJWBE nixchad@blueberry"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQ77pbUwzNYJzu/vEg9MqtuLQmjgRtf5b4K+qsZ0o7v nixchad@blackberry"
  ];
  programs.ssh.knownHosts.blackberry.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFuPxeQsCC2PkR21MSxgkAYDFqJ6sARXZLZRHuy99oq";

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
      kbdInteractiveAuthentication = false;
      hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = "4096";
        }
      ];
    };
  };

  sops.defaultSopsFile = ../../secrets/default.yaml;
  sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
  sops.gnupg.sshKeyPaths = lib.mkForce [];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;

  services.smartd.enable = true;
  services.smartd.defaults.monitored = "-a -o on -s (S/../01/./03|L/(01|07)/.././03)";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = lib.mkDefault "22.05"; # Did you read the comment?
}
