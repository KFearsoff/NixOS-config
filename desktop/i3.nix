{ lib, pkgs, ... }:

let
  fontSize = 10.8;
  fonts = {
    names = [ "noto-fonts" ];
    size = fontSize;
  };
  workspaces = [ "" "" "" "" "" "" "" "" "" ];
  numbers = map toString (lib.range 1 9);
  # TODO: rename workspaces to get extra style points
  workspaceNumbers = lib.zipListsWith (x: y: x + "" + y) numbers workspaces;
  useWithModifier = mod: lib.mapAttrs' (k: v: lib.nameValuePair (mod + "+" + k) v);
  appendExecToCommand = lib.mapAttrs' (k: v: lib.nameValuePair k ("exec" + v));
in {
  enable = true;
  package = pkgs.i3-gaps; 

  config = rec {
    inherit fonts;
    modifier = "Mod4";

    gaps = {
      inner = 5;
    };

    bars = [{
      position = "top";
      colors.separator = "#B5B5B5";
      extraConfig = ''
        separator_symbol |
      '';
    }];

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

    modes = {
      resize = {
        h = "resize shrink width 5 px or 5 ppt";
        j = "resize shrink height 5 px or 5 ppt";
        k = "resize grow height 5 px or 5 ppt";
        l = "resize grow width 5 px or 5 ppt";
        Down = "resize grow height 5 px or 5 ppt";
        Left = "resize shrink width 5 px or 5 ppt";
        Right = "resize grow width 5 px or 5 ppt";
        Up = "resize shrink height 5 px or 5 ppt";
        Return = "mode default";
        Escape = "mode default";
      };
    };
    # template = { border = "#"; background = "#"; text = "#"; indicator = "#"; childBorder = "#"; };
    # Colors from https://github.com/inix121/i3wm-themer/blob/master/themes/001.yml
    colors = {
      background = "#1E272B";

      focused = {
        border = "#EAD49B"; 
        background = "#1E272B"; 
        text = "#EAD49B"; 
        indicator = "#9D6A47"; 
        childBorder = "#9D6A47"; 
      };
      unfocused = { 
        border = "#EAD49B"; 
        background = "#1E272B"; 
        text = "#EAD49B"; 
        indicator = "#78824B"; 
        childBorder = "#78824B"; 
      };
      focusedInactive = { 
        border = "#EAD49B"; 
        background = "#1E272B"; 
        text = "#EAD49B"; 
        indicator = "#78824B"; 
        childBorder = "#78824B"; 
      };
      urgent = { 
        border = "#EAD49B"; 
        background = "#1E272B"; 
        text = "#EAD49B"; 
        indicator = "#78824B"; 
        childBorder = "#78824B"; 
      };
      placeholder = { 
        border = "#EAD49B"; 
        background = "#1E272B"; 
        text = "#EAD49B"; 
        indicator = "#78824B"; 
        childBorder = "#78824B"; 
      };
    };

    keybindings = useWithModifier modifier ({
      "Tab" = "workspace back_and_forth";
      "Shift+q" = "kill";      
      "Return" = "exec DRI_PRIME=1 alacritty";
      "Shift+Return" = "exec ee";
      "d" = "exec rofi -combi-mode drun#run -show combi";
      "q" = "exec rofi-pass";
      "Escape" = "exec xautolock -locknow";
      "Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
      "Shift+r" = "restart";
      "r" = "mode resize";

      "space" = "focus mode_toggle";
      "Shift+space" = "floating toggle";

      "s" = "layout stacking";
      "w" = "layout tabbed";
      "e" = "layout toggle split";
      "v" = "split v";
      "g" = "split h";
      "a" = "focus parent";

      "h" = "focus left";
      "j" = "focus down";
      "k" = "focus up";
      "l" = "focus right";
      "Left" = "focus left";
      "Down" = "focus down";
      "Up" = "focus up";
      "Right" = "focus right";
      "Shift+h" = "move left";
      "Shift+j" = "move down";
      "Shift+k" = "move up";
      "Shift+l" = "move right";
      "Shift+Left" = "move left";
      "Shift+Down" = "move down";
      "Shift+Up" = "move up";
      "Shift+Right" = "move right";

      "Shift+plus" = "gaps inner current plus 5";
      "Shift+minus" = "gaps inner current minus 5";

      "f" = "fullscreen toggle";
    } // lib.foldl (x: y: x // y) { } (lib.zipListsWith (i: n: {
      "${i}" = "workspace ${n}";
      "Shift+${i}" = "move container to workspace ${n}; workspace ${n}";
    }) numbers workspaceNumbers)) //appendExecToCommand ({
      "XF86AudioRaiseVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "--no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "--no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "Print" = "exec flameshot gui";
    });
  };
}
 
    
