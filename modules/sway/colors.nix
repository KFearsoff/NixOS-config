{ config, nix-colors, ... }:

let colorscheme = nix-colors.colorSchemes.dracula;
in
{
      background = "#${colorscheme.colors.base07}";

      focused = {
        border = "#${colorscheme.colors.base05}";
        background = "#${colorscheme.colors.base0D}";
        text = "#${colorscheme.colors.base00}";
        indicator = "#${colorscheme.colors.base0D}";
        childBorder = "#${colorscheme.colors.base0D}";
      };
      focusedInactive = { 
        border = "#${colorscheme.colors.base01}";
        background = "#${colorscheme.colors.base01}";
        text = "#${colorscheme.colors.base05}";
        indicator = "#${colorscheme.colors.base03}";
        childBorder = "#${colorscheme.colors.base01}";
      };
      unfocused = { 
        border = "#${colorscheme.colors.base01}";
        background = "#${colorscheme.colors.base00}";
        text = "#${colorscheme.colors.base05}";
        indicator = "#${colorscheme.colors.base01}";
        childBorder = "#${colorscheme.colors.base01}";
      };
      urgent = { 
        border = "#${colorscheme.colors.base08}";
        background = "#${colorscheme.colors.base08}";
        text = "#${colorscheme.colors.base00}";
        indicator = "#${colorscheme.colors.base08}";
        childBorder = "#${colorscheme.colors.base08}";
      };
      placeholder = { 
        border = "#${colorscheme.colors.base00}";
        background = "#${colorscheme.colors.base00}";
        text = "#${colorscheme.colors.base05}";
        indicator = "#${colorscheme.colors.base00}";
        childBorder = "#${colorscheme.colors.base00}";
      };
  }
