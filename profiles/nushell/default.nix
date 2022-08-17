{
  username,
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.config.packageOverrides = {
    nushell = pkgs.callPackage "${inputs.nushell-066}/pkgs/shells/nushell" {
      inherit (pkgs.darwin.apple_sdk.frameworks) AppKit Foundation Security;
      inherit (pkgs.darwin.apple_sdk) sdk;
    };
  };
  home-manager.users."${username}" = {
    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;
    };
  };
}
