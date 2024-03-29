#!/usr/bin/env bash

# Adapted to Sway and NixOS from this:
# https://gist.github.com/haselwarter/5e1b16bf6288a4a0376ca6480da4d6d6

# Switches workspaces in Sway like Xmonad.
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
# bindsym $mod+1 exec --no-startup-id swap-workspaces $ws1
#
# (assuming this script is named 'swap-workspaces' and available in $PATH)

# Changes from the original version are:
# 1. From #!/bin/bash shebang to #!/usr/bin/env bash shebang for NixOS compatibility
# 2. swaymsg adds a space after a colon, so regexes are changed to accomodate for that
# 3. If the target workspace is invisible and on another output, it jumps to the
# current output without affecting the other workspace
# -----------------------------------------------

set -euxo pipefail

declare ws_target  # $1 == target workspace
declare ws_visible # whether ws_target is visible
declare op_current # current output
declare op_target  # target output
declare msg        # commands passed to swaymsg

ws_target=$1

[[ $ws_target ]] || {
  echo "usage: ${0##*/} WORKSPACE" >&2
  exit 1
}

function get_outputs() {
  op_current=$(swaymsg -t get_workspaces | jq ".[] | select(.focused == true) | .output")
  op_target=$(swaymsg -t get_workspaces | jq ".[] | select(.name == \"$ws_target\") | .output")
}

function do_all_else() {
  if [[ -z $op_target ]]; then # ws_target doesn't exist
    # create ws_target
    msg+="workspace $ws_target"
  else
    # check if the target is visible
    ws_visible=$(swaymsg -t get_workspaces | jq -r ".[] | select(.name == \"$ws_target\") | .visible")

    # if the target is on a different output and visible, swap outputs
    # if the target is on a different output and not visible,
    # display the target while leaving the other output intact
    if [ "$op_target" != "$op_current" ]; then

      if [ "$ws_visible" = "true" ]; then # target visible; swap outputs
        msg+="move workspace to output $op_target;"
        msg+="[workspace=$ws_target] move workspace to output $op_current;"
        msg+="workspace $ws_target"
      else # target not visible; bring target to current output
        msg+="[workspace=$ws_target] move workspace to output $op_current;"
        msg+="workspace $ws_target"
      fi

    else
      msg+="workspace $ws_target" # target on the same workspace; just focus it
    fi
  fi
}

function actual_run() {
  swaymsg "$msg"
}

get_outputs
do_all_else
actual_run
