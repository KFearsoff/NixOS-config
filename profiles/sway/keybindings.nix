{
  config,
  lib,
  pkgs,
  mod,
  ...
}: let
  # TODO: rename workspaces to get extra style points
  workspaces = ["" "" "" "" "" "" "" "" ""];
  numbers = map toString (lib.range 1 9);
  workspaceNumbers = lib.zipListsWith (x: y: x + "" + y) numbers workspaces;
  useWithModifier = mod: lib.mapAttrs' (k: lib.nameValuePair (mod + "+" + k));
  appendExecToCommand = lib.mapAttrs' (k: v: lib.nameValuePair k ("exec " + v));
  swap = pkgs.writeShellScript "swap-workspaces" (builtins.readFile ./swap-workspaces.sh);

  /*
    On the basic level, this magic spell maps workspace-related hotkeys to the numbers on the keyboard.
   It does so by applying a function inside the squiggly brackets to hotkeys and workspaces to produce
   attribute sets, then by merging those attribute sets together.
   func -> nul -> (number -> workspace -> attrSet) -> attrSetForAllNumbers
   */
  navigation = lib.foldl (old: new: old // new) {} (lib.zipListsWith
    (number: workspace: {
      "${mod}+${number}" = "exec --no-startup-id ${swap} ${workspace}";
      "${mod}+Shift+${number}" = "move container to workspace ${workspace}; workspace ${workspace}";
    })
    numbers
    workspaceNumbers);

  functionKeys = appendExecToCommand {
    "XF86AudioRaiseVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
    "XF86AudioLowerVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
    "XF86AudioMute" = "--no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
    "XF86AudioMicMute" = "--no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
    "XF86MonBrightnessUp" = "${pkgs.light}/bin/light -A 5";
    "XF86MonBrightnessDown" = "${pkgs.light}/bin/light -U 5";
    "Print" = "${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
    "${mod}+Print" = "${pkgs.sway-contrib.grimshot}/bin/grimshot save area";
  };

  general = useWithModifier mod {
    "Tab" = "workspace back_and_forth";
    "Shift+q" = "kill";
    "Return" = "exec ${config.terminal.binaryPath}";
    "d" = "exec ${pkgs.rofi-wayland}/bin/rofi -combi-mode drun -show drun -icon-theme \"Papirus\" -show-icons";
    "Caps_Lock" = "exec ${pkgs.swaylock}/bin/swaylock -i ~/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png";
    "Shift+e" = "exec ${pkgs.wlogout}/bin/wlogout";
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

    "Shift+equal" = "gaps inner current plus 1";
    "Shift+minus" = "gaps inner current minus 1";

    "f" = "fullscreen toggle";
  };
in
  general // navigation // functionKeys
