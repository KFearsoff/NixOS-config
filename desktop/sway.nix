{ lib, pkgs, ... }:

let
  workspaces = [ "" "" "" "" "" "" "" "" "" ];
  numbers = map toString (lib.range 1 9);
  # TODO: rename workspaces to get extra style points
  workspaceNumbers = lib.zipListsWith (x: y: x + "" + y) numbers workspaces;
  useWithModifier = mod: lib.mapAttrs' (k: v: lib.nameValuePair (mod + "+" + k) v);
  appendExecToCommand = lib.mapAttrs' (k: v: lib.nameValuePair k ("exec " + v));
  gsettings = "${pkgs.glib}/bin/gsettings";
  gnomeSchema = "org.gnome.desktop.interface";
  importGsettings = pkgs.writeShellScript "import_gsettings.sh" ''
    config="/home/alternateved/.config/gtk-3.0/settings.ini"
    if [ ! -f "$config" ]; then exit 1; fi
    gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
    font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
    ${gsettings} set ${gnomeSchema} gtk-theme "$gtk_theme"
    ${gsettings} set ${gnomeSchema} icon-theme "$icon_theme"
    ${gsettings} set ${gnomeSchema} cursor-theme "$cursor_theme"
    ${gsettings} set ${gnomeSchema} font-name "$font_name"
  '';
in {
  enable = true;
  wrapperFeatures.gtk = true;

  config = rec {
    startup = [{ command = "${importGsettings}"; }];

    modifier = "Mod4";
    bindkeysToCode = true;

    input = { "type:keyboard" = import ./keymap.nix; };

    output = {
      HDMI-A-1 = {
        pos = "0 0";
        bg = "/home/user/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png fill";
      };
      HDMI-A-2 = {
        pos = "1920 0";
        bg = "/home/user/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png fill";
      };
    };

    gaps = {
      inner = 5;
    };

    bars = [{ command = "waybar"; }];
   # {
   #   position = "top";
   #   colors.separator = "#B5B5B5";
   #   extraConfig = ''
   #     separator_symbol 
   #   '';
   #   fonts.size = 10.0;
   # }];

    window = {
      border = 1;
      hideEdgeBorders = "smart";
      commands = [
        # Force use border on all windows
        { command = "border pixel 1"; criteria = { title = ".*"; }; }
      ];
    };

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
      "Escape" = "exec swaylock -i ~/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png";
      "Shift+e" = "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";
      "Shift+r" = "reload";
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
      "${i}" = "move workspace to output left";
      "Control+${i}" = "workspace ${n}";
      "Shift+${i}" = "move container to workspace ${n}; workspace ${n}";
    }) numbers workspaceNumbers)) // appendExecToCommand ({
      "XF86AudioRaiseVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "--no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "--no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "Print" = "grim -g \"$(slurp)\" - | wl-copy";
    });
  };
}
 
    