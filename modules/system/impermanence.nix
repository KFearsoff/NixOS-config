{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.impermanence;
in {
  options.nixchad.impermanence = {
    enable = mkEnableOption "impermanence";
  };

  config = mkIf cfg.enable {
    boot.cleanTmpDir = true;
    programs.fuse.userAllowOther = true;

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
      ];
    };

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
  };
}
