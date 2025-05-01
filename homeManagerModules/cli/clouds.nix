{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixchad.clouds;
  inherit (lib)
    mkEnableOption
    mkIf
    optional
    optionals
    ;
in
{
  options.nixchad.clouds = {
    enable = mkEnableOption "cloud tools";
    azure = mkEnableOption "Azure CLI";
    aws = mkEnableOption "AWS CLI";
    gcp = mkEnableOption "GCP CLI";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      (optionals cfg.enable [
        terraform
        terragrunt
      ])
      ++ (optional cfg.azure azure-cli)
      ++ (optionals cfg.aws [
        awscli2
        aws-vault
      ])
      ++ (optional cfg.gcp (
        google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ]
      ));
  };
}
