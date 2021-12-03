#!/usr/bin/env bash

# Switches workspaces in Sway like xmonad.
# Always bring the requested workspace to the
# focused monitor ("output" in Sway's terminology).
# If the requested workspace is on another monitor,
# the current workspace and requested workspace 
# will swap positions with each other.

# ~/.config/sway/config
# set $ws1 "1"
#
# from this:
# bindsym $mod+1 workspace number $ws1
#
# to this:
# bindsym $mod+1 exec --no-startup-id wsmove $ws1
#
# (assuming this script is named 'wsmove' and available in $PATH)
# -----------------------------------------------

declare ws_target  # $1 == target workspace
declare ws_visible # whether ws_target is visible
declare op_current # current output
declare op_target  # target output
declare re_target  # regex to get op_target
declare re_current # regex to get op_current
declare re_visible # regex to get ws_visible 
declare msg        # commands passed to swaymsg

ws_target=$1

[[ $ws_target ]] || {
  echo "usage: ${0##*/} WORKSPACE" >&2
  exit 1
}

json=$(swaymsg -t get_workspaces)

re_target='"name": "'"$ws_target"'"[^}]+"output": "([^"]+)'
re_current='"output": "([^"]+)[^}]+"focused": true[^}]+}'


[[ $json =~ $re_current ]] && op_current=${BASH_REMATCH[1]}


if [[ $json =~ $re_target ]]; then
  op_target=${BASH_REMATCH[1]}
  echo $ws_target
  echo $op_target
  echo $json
  re_visible='"name": "'"$ws_target"'"[^}]+"output": "'"$op_target"'"[^}]+"visible": ([^[:space:]]*)[^}]+}'
  echo $re_visible
  if [[ $json =~ $re_visible ]]; then ws_visible=${BASH_REMATCH[1]}; fi
  echo $ws_visible

  # only swap monitors if the workspaces are on 
  # different outputs and the target is not visible
  if [ $op_target != $op_current ]; then
	  if [ $ws_visible = "true" ]; then
		  msg+="move workspace to output $op_target;"
		  msg+="[workspace=$ws_target] move workspace to output $op_current;"
	  else
		  msg+="[workspace=$ws_target] move workspace to output $op_current;"
	  fi
  fi
#    msg+="move workspace to output $op_target;"
#    msg+="[workspace=$ws_target] move workspace to output $op_current;"
#  fi
#  [ $op_target = $op_current ] && [ $ws_visible = "true" ] && {
#    # move the current workspace to op_target
#    # we don't need to know the current workspace 
#    # name for this to work.
#    msg+="move workspace to output $op_target;"
#    msg+="[workspace=$ws_target] move workspace to output $op_current;"
#  }

else # ws_target doesn't exist
  # create ws_target
  msg+="workspace --no-auto-back-and-forth $ws_target;"
  # move ws_target to op_current in case it was
  # "assigned" to a different output. swapping 
  # outputs is probably not what we want
  msg+="[workspace=$ws_target] move workspace to output $op_current;"
fi

# always focus ws_target
msg+="workspace --no-auto-back-and-forth $ws_target"
swaymsg "$msg"
