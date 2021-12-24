{ colorscheme, ... }:

{
  enable = true;
  settings = {
    colors = {
      primary = {
        background = "0x${colorscheme.colors.base00}";
        foreground = "0x${colorscheme.colors.base05}";
      };

      cursor = {
        text = "0x${colorscheme.colors.base00}";
        cursor = "0x${colorscheme.colors.base05}";
      };

      normal = {
        black = "0x${colorscheme.colors.base00}";
        red = "0x${colorscheme.colors.base08}";
        green = "0x${colorscheme.colors.base0B}";
        yellow = "0x${colorscheme.colors.base0A}";
        blue = "0x${colorscheme.colors.base0D}";
        magenta = "0x${colorscheme.colors.base0E}";
        cyan = "0x${colorscheme.colors.base0C}";
        white = "0x${colorscheme.colors.base05}";
      };

      bright = {
        black = "0x${colorscheme.colors.base03}";
        red = "0x${colorscheme.colors.base09}";
        green = "0x${colorscheme.colors.base01}";
        yellow = "0x${colorscheme.colors.base02}";
        blue = "0x${colorscheme.colors.base04}";
        magenta = "0x${colorscheme.colors.base06}";
        cyan = "0x${colorscheme.colors.base0F}";
        white = "0x${colorscheme.colors.base07}";
      };

      draw_bold_test_with_bright_colors = false;
    };

    font.size = 14.0;
    background_opacity = 0.85;
  };
}
