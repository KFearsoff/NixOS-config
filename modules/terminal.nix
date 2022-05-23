{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.terminal;
in {
  options.terminal = rec {
    enable = mkEnableOption "declarative management of terminal";

    package = mkOption {
      type = types.package;
      default = pkgs.kitty;
      defaultText = literalExpression "pkgs.kitty";
      description = ''
        The shell package to use.
      '';
    };

    name = mkOption {
      type = types.str;
      default = "${cfg.package.pname}";
      defaultText = literalExpression "kitty";
      description = ''
        The shell name.
      '';
    };

    binaryPath = mkOption {
      type = types.path;
      default = "${cfg.package}/bin/${cfg.name}";
      defaultText = literalExpression "\${pkgs.kitty}/bin/kitty";
      description = ''
        Path to the shell binary.
      '';
    };
  };
}
