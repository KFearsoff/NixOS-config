{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.nixchad.nushell;
in {
  options.nixchad.nushell = {
    enable = mkEnableOption "nushell";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.nushell = {
        enable = true;
        configFile.source = ./config.nu;
        envFile.source = ./env.nu;
        environmentVariables = {
          EDITOR = "hx";
        };
        extraConfig = ''
          use ${inputs.nu-scripts}/aliases/git/git-aliases.nu *
          use ${inputs.nu-scripts}/custom-completions/cargo/cargo-completions.nu *
          use ${inputs.nu-scripts}/custom-completions/git/git-completions.nu *
          use ${inputs.nu-scripts}/custom-completions/man/man-completions.nu *
          use ${inputs.nu-scripts}/custom-completions/nix/nix-completions.nu *
        '';
        # use ${inputs.nu-scripts}/modules/docker/docker.nu *
      };
    };
  };
}
