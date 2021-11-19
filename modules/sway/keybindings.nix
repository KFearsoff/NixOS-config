{ lib, pkgs, mod, ... }:

let
  workspaces1 = [ "" "" "" "" "" "" "" "" "" ];
  numbers = map toString (lib.range 1 9);
  # TODO: rename workspaces to get extra style points
  workspaceNumbers = lib.zipListsWith (x: y: x + "" + y) numbers workspaces1;
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
  swapScript = pkgs.callPackage ./swap-workspaces.nix { };
  swap = "${swapScript}/bin/swap-workspaces";


  /* On the basic level, this magic spell maps workspace-related hotkeys to the numbers on the keyboard.
    It does so by applying a function inside the squiggly brackets to hotkeys and workspaces to produce
    attribute sets, then by merging those attribute sets together.
    func -> nul -> (number -> workspace -> attrSet) -> attrSetForAllNumbers */
  workspaces = lib.foldl (old: new: old // new) { } (lib.zipListsWith (number: workspace: {
      "${mod}+${number}" = "exec --no-startup-id ${swap} ${workspace}";
      "${mod}+Control+${number}" = "workspace ${workspace}";
      "${mod}+Shift+${number}" = "move container to workspace ${workspace}; workspace ${workspace}";
    }) numbers workspaceNumbers);

    functionKeys = appendExecToCommand ({
      "XF86AudioRaiseVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "--no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "--no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "Print" = "grim -g \"$(slurp)\" - | wl-copy";
    });

    general = useWithModifier mod ({
      "Tab" = "workspace back_and_forth";
      "Shift+q" = "kill";      
      "Return" = "exec DRI_PRIME=1 alacritty";
      "Shift+Return" = "exec ee";
      "d" = "exec rofi -combi-mode drun#run -show combi";
      "Caps_Lock" = "exec swaylock -i ~/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png";
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
    });
in
    general // workspaces // functionKeys
