{
  config,
  lib,
  nix-colors,
  ...
}:
with lib; let
  cfg = config.nixchad.colors;
  dracula-patched = {
    slug = "dracula";
    name = "Dracula";
    author = "https://github.com/m-dango/base16-dracula-scheme/tree/76cf0bf41d8a1098ce1f43f86bb0413a1dc26e69";
    colors = {
      base00 = "282a36"; # Background
      base01 = "343746"; # Lighter Background
      base02 = "44475a"; # Selection
      base03 = "6272a4"; # Comments
      base04 = "999999"; # Dark Foreground (status bars)
      base05 = "f8f8f2"; # Foreground
      base06 = "f8f8f2"; # Light Foreground
      base07 = "f8f8f2"; # Light Background
      base08 = "ff5555"; # Red
      base09 = "bd93f9"; # Purple
      base0A = "f1fa8c"; # Yellow
      base0B = "50fa7b"; # Green
      base0C = "8be9fd"; # Cyan
      base0D = "66d9ef"; # Blue (Soft Cyan from Atom)
      base0E = "ff79c6"; # Pink
      base0F = "ffb86c"; # Orange
    };
  };
in {
  options.nixchad.colors = {
    enable = mkEnableOption "colors";
  };

  config = mkIf cfg.enable {
    hm = {
      imports = [nix-colors.homeManagerModule];
      # config.colorScheme = nix-colors.colorSchemes.dracula;
      config.colorScheme = dracula-patched;
    };
  };
}
