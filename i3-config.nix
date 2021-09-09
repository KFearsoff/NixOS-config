{ lib, ... }:
rec {
  modifier = "Mod4";
  modes = {};

  window = {
    border = 1;
    hideEdgeBorders = "both";
    commands = [
      # Force use border on all windows
      { command = "border pixel 1"; criteria = { title = ".*"; }; }
    ];
  };

  startup = [
    { command = "onboard"; notification = false; }
  ];

  # template = { border = "#"; background = "#"; text = "#"; indicator = "#"; childBorder = "#"; };
  # Colorss from https://github.com/inix121/i3wm-themer/blob/master/themes/001.yml
  colors = {
    background = "#1E272B";

    focused = { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#9D6A47"; childBorder = "#9D6A47"; };
    unfocused = { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
    focusedInactive = { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
    urgent = { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
    placeholder = { border = "#EAD49B"; background = "#1E272B"; text = "#EAD49B"; indicator = "#78824B"; childBorder = "#78824B"; };
  };

    keybindings =
    let
      mod = modifier;
      workspaces = with lib; listToAttrs (
      (map (i: nameValuePair "${mod}+${i}" "workspace number ${i}") (map toString (range 0 9))) ++
      (map (i: nameValuePair "${mod}+Shift+${i}" "move container to workspae number ${i}") (map toString (range 0 9))));
    in lib.mkDefault ({
      "${mod}+Tab" = "workspace back_and_forth";
      "${mod}+Shift+q" = "kill";      
      "${mod}+Return" = "exec DRI_PRIME=1 alacritty";
      "${mod}+Shift+Return" = "exec ee";
      "${mod}+d" = "exec rofi -combi-mode drun#run -show combi";
      "${mod}+q" = "exec rofi-pass";
      "${mod}+Escape" = "exec xautolock -locknow";
      "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
      
      "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";

      "${mod}+space" = "focus mode_toggle";
      "${mod}+Shift+space" = "floating toggle";

      "${mod}+s" = "layout stacking";
      "${mod}+w" = "layout tabbed";
      "${mod}+e" = "layout toggle split";
      "${mod}+v" = "split v";

      "${mod}+j" = "focus left";
      "${mod}+k" = "focus down";
      "${mod}+l" = "focus up";
      "${mod}+semicolon" = "focus right";

      "${mod}+Shift+j" = "move left";
      "${mod}+Shift+k" = "move down";
      "${mod}+Shift+l" = "move up";
      "${mod}+Shift+colon" = "move right";

      "${mod}+f" = "fullscreen toggle";
    } // workspaces);
    
    bars = [
      {
        position = "bottom";
        colors.separator = "#B5B5B5";
        extraConfig = ''
          separator_symbol |
        '';
      }
    ];
  }
