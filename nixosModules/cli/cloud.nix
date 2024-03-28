{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.cloud;
in {
  options.nixchad.cloud = {
    enable = mkEnableOption "cloud cli and other stuff";
  };

  config = mkIf cfg.enable {
    hm = {
      home = {
        packages = with pkgs; [
          (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
          awscli2
          azure-cli
        ];
      };
    };
  };
}
