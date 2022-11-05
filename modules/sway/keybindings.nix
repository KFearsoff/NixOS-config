{
  config,
  lib,
  pkgs,
  mod,
  ...
}: with lib; let
  # TODO: rename workspaces to get extra style points
  workspaces = ["" "" "" "" "" "" "" "" ""];
  numbers = map toString (range 1 9);
  workspaceNumbers = zipListsWith (x: y: x + "" + y) numbers workspaces;

  useWithModifier = mod: mapAttrs' (k: v: nameValuePair (mod + "+" + k) v);
  appendExecToCommand = mapAttrs' (k: v: nameValuePair k ("exec " + v));

  swap = pkgs.writeShellScript "swap-workspaces" (builtins.readFile ./swap-workspaces.sh);
  change-codec = pkgs.writeShellScript "change-codec" (builtins.readFile ./change-codec.sh);

  navigationList = zipListsWith 
    (number: workspace: {
      "${mod}+${number}" = "exec --no-startup-id ${swap} ${workspace}";
      "${mod}+Shift+${number}" = "move container to workspace ${workspace}; workspace ${workspace}";
    })
    numbers
    workspaceNumbers;



  navigation = foldl (old: new: old // new) {} navigationList;

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
    "Caps_Lock" = "exec ${pkgs.swaylock}/bin/swaylock -i ~/NixOS-config/assets/nix-wallpaper-nineish-dark-gray.png";
    "Shift+e" = "exec ${pkgs.wlogout}/bin/wlogout";

    "Shift+equal" = "gaps inner current plus 1";
    "Shift+plus" = "gaps inner current minus 1";

    "m" = "exec --no-startup-id ${change-codec}";
  };
in
  general // navigation // functionKeys
