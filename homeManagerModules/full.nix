{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.nixchad.full = {
    enable = mkEnableOption "fully customized configuration" // {default = true;};
  };
}
