{ config, ... }:

with config.home-manager.users.user.colorscheme.colors; {
  background = "#${base07}";

  focused = {
    border = "#${base05}";
    background = "#${base0D}";
    text = "#${base00}";
    indicator = "#${base0D}";
    childBorder = "#${base0D}";
  };
  focusedInactive = { 
    border = "#${base01}";
    background = "#${base01}";
    text = "#${base05}";
    indicator = "#${base03}";
    childBorder = "#${base01}";
  };
  unfocused = { 
    border = "#${base01}";
    background = "#${base00}";
    text = "#${base05}";
    indicator = "#${base01}";
    childBorder = "#${base01}";
  };
  urgent = { 
    border = "#${base08}";
    background = "#${base08}";
    text = "#${base00}";
    indicator = "#${base08}";
    childBorder = "#${base08}";
  };
  placeholder = { 
    border = "#${base00}";
    background = "#${base00}";
    text = "#${base05}";
    indicator = "#${base00}";
    childBorder = "#${base00}";
  };
}
