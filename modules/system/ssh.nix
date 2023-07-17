{
  config,
  lib,
  ...
}: let
  cfg = config.nixchad.impermanence;
in {
  nixchad.impermanence.persisted.values = [
    {
      files =
        lib.mkIf cfg.presets.essential (lib.concatMap (key: [key.path (key.path + ".pub")]) config.services.openssh.hostKeys);
    }
  ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
