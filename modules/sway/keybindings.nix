{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  mod = config.nixchad.sway.modifier;
  # TODO: rename workspaces to get extra style points
  workspaces = ["" "" "" "" "" "" "" "" ""];
  numbers = map toString (range 1 9);
  workspaceNumbers = zipListsWith (x: y: x + "" + y) numbers workspaces;

  useWithModifier = mapAttrs' (k: nameValuePair (mod + "+" + k));
  appendExecToCommand = mapAttrs' (k: v: nameValuePair k ("exec " + v));

  swap = pkgs.writeShellScript "swap-workspaces" (builtins.readFile ./swap-workspaces.sh);

  navigationList =
    zipListsWith
    (number: workspace: {
      "${mod}+${number}" = "exec --no-startup-id ${swap} ${workspace}";
      "${mod}+Shift+${number}" = "move container to workspace ${workspace}; workspace ${workspace}";
    })
    numbers
    workspaceNumbers;

  navigation = foldl (old: new: old // new) {} navigationList;

  functionKeys = appendExecToCommand ({
      "XF86AudioRaiseVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "--no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "--no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "--no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";

      "Print" = "${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
      "${mod}+Print" = "${pkgs.sway-contrib.grimshot}/bin/grimshot save area";
    }
    // optionalAttrs config.nixchad.sway.backlight {
      "XF86MonBrightnessUp" = "${pkgs.light}/bin/light -A 5";
      "XF86MonBrightnessDown" = "${pkgs.light}/bin/light -U 5";
    });

  general = useWithModifier {
    "Caps_Lock" = "exec ${pkgs.systemd}/bin/loginctl lock-session";
    "Shift+e" = "exec ${pkgs.wlogout}/bin/wlogout";

    "Shift+equal" = "gaps inner current plus 1";
    "Shift+plus" = "gaps inner current minus 1";

    "o" = "exec --no-startup-id ${pkgs.wtype}/bin/wtype $(grep -v '^//' ~/Documents/Notes/Reference\\ notes/Bookmarks.md | rofi -dmenu | cut -d' ' -f1)"; # bookmark script by LukeSmith: https://youtu.be/d_11QaTlf1I
  };
in {
  hm = {
    wayland.windowManager.sway.config.keybindings = mkOptionDefault (general // navigation // functionKeys);
  };
}
