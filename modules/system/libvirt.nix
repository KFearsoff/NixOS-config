{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.libvirt;
in {
  options.nixchad.libvirt = {
    enable = mkEnableOption "libvirt";
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    users.users."${username}".extraGroups = ["libvirtd"];

    hm.home.packages = mkIf config.nixchad.gui.enable [
      pkgs.virt-manager
    ];
  };
}
