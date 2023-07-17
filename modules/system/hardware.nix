{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.hardware;
in {
  options.nixchad.hardware = {
    enable = mkEnableOption "enable settings that make sense for a baremetal host";
  };

  config = mkIf cfg.enable {
    services.smartd.enable = true;
    services.smartd.defaults.monitored = mkDefault "-a -o on -s (S/../01/./03|L/(01|07)/.././03)";
    services.fwupd.enable = true;

    nixchad.impermanence.persisted.values = [
      {
        directories =
          lib.mkIf config.nixchad.impermanence.presets.essential ["/var/lib/fwupd"];
      }
    ];
  };
}
