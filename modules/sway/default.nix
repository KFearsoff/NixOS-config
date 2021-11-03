{ outputConfig, ... }:

{
  enable = true;
  wrapperFeatures.gtk = true;
  config = {
    modifier = "Mod4";
    bindkeysToCode = true;

    input = { "type:keyboard" = import ./keymap.nix; };

    output = outputConfig;

    gaps = { inner = 5; };

    bars = import ./waybar.nix;

    colors = import ./colors.nix;

    keybindings = import ./keybindings.nix;
  };
}
