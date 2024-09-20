{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.kubernetes;
in
{
  options.nixchad.kubernetes = {
    enable = mkEnableOption "kubernetes";
  };

  config = mkIf cfg.enable {
    hm = {
      home = {
        packages =
          with pkgs;
          [
            kubectl
            kubernetes-helm
            # minikube
          ]
          ++ optional config.nixchad.gui.enable openlens;

        file = optionalAttrs config.nixchad.libvirt.enable {
          # Patch Minikube kvm2 driver, see https://github.com/NixOS/nixpkgs/issues/115878
          ".minikube/bin/docker-machine-driver-kvm2".source = "${pkgs.docker-machine-kvm2}/bin/docker-machine-driver-kvm2";
        };
      };
    };
  };
}
