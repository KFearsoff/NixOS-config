{
  username,
  inputs,
  pkgs,
  ...
}:
{
 nixpkgs.config.packageOverrides = {
  nushell = pkgs.callPackage "${inputs.nushell-066}/pkgs/shells/nushell" {inherit (pkgs.darwin.apple_sdk.frameworks) AppKit Security;};
};
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      autosuggestions = {
        enable = true;
        async = true;
      };
      vteIntegration = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
    };
    users.defaultUserShell = pkgs.zsh;

    home-manager.users."${username}" = {
      programs.nushell = {
        enable = true;
        configFile.source = ./config.nu;
        envFile.source = ./env.nu;
      };
    };
}
