{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.terminal;
in
{
  options.terminal = {
    enable = mkEnableOption "declarative management of terminal";

    package = mkOption {
      type = types.package;
      default = pkgs.kitty;
      defaultText = literalExpression "pkgs.kitty";
      description = ''
        The terminal package to use.
      '';
    };

    name = mkOption {
      type = types.str;
      default = "${cfg.package.pname}";
      defaultText = literalExpression "kitty";
      description = ''
        The terminal name.
      '';
    };

    binaryPath = mkOption {
      type = types.path;
      default = "${cfg.package}/bin/${cfg.name}";
      defaultText = literalExpression "\${pkgs.kitty}/bin/kitty";
      description = ''
        Path to the terminal binary.
      '';
    };

    windowName = mkOption {
      type = types.str;
      default = "${cfg.name}";
      defaultText = literalExpression "kitty";
      description = ''
        The terminal window's name. Useful when you want to pin a terminal to the workspace with Sway/i3.
      '';
    };
  };
}
