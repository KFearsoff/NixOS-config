{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.zsh;
in {
  imports = [./aliases.nix];

  options.nixchad.zsh = {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
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

    hm = {
      programs.zsh = {
        enable = true;
        autocd = true;
        history.expireDuplicatesFirst = true;
        history.extended = true;
      };
    };
  };
}
