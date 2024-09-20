{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.nixchad.nushell;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.nixchad.nushell = {
    enable = mkEnableOption "nushell" // {
      default = config.nixchad.full.enable;
    };
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;

      # Both are manually regenerated if Nushell breaks when updating
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;

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
}
