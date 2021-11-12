with import <nixpkgs> { }; stdenv.mkDerivation {
  name = "swap-workspaces";
  buildInputs = [ bash autoPatchelfHook makeWrapper ];
  src = ./swap-workspaces.sh; 
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin
  '';
#  ''
#    #!/bin/bash
#    
#    # Switches workspaces in i3 like xmonad.
#    # Always bring the requested workspace to the
#    # focused monitor ("output" in i3's terminology).
#    # If the requested workspace is on another monitor,
#    # the current workspace and requested workspace 
#    # will swap positions with each other.
#    
#    # ~/.config/i3/config
#    # set $ws1 "1"
#    #
#    # from this:
#    # bindsym $mod+1 workspace number $ws1
#    #
#    # to this:
#    # bindsym $mod+1 exec --no-startup-id wsmove $ws1
#    #
#    # (assuming this script is named 'wsmove' and available in $PATH)
#    # -----------------------------------------------
#    
#    declare ws_target  # $1 == target workspace
#    declare op_current # current output
#    declare op_target  # target output
#    declare re_target  # regex to get op_target
#    declare re_current # regex to get op_current
#    declare msg        # commands passed to swaymsg
#    
#    ws_target=$1
#    
#    [[ $ws_target ]] || {
#      echo "usage: ${0##*/} WORKSPACE" >&2
#      exit 1
#    }
#    
#    json=$(swaymsg -t get_workspaces)
#    
#    re_target='"name":"'"$ws_target"'[^}]+},"output":"([^"]+)'
#    re_current='"focused":true[^}]+},"output":"([^"]+)'
#    
#    [[ $json =~ $re_current ]] && op_current=${BASH_REMATCH[1]}
#    
#    if [[ $json =~ $re_target ]]; then
#      op_target=${BASH_REMATCH[1]}
#    
#      # only swap monitors if the workspaces are on 
#      # different outputs
#      [[ $op_target = "$op_current" ]] || {
#        # move the current workspace to op_target
#        # we don't need to know the current workspace 
#        # name for this to work.
#        msg+="move workspace to output $op_target;"
#        msg+="[workspace=$ws_target] move workspace to output $op_current;"
#      }
#    
#    else # ws_target doesn't exist
#      # create ws_target
#      msg+="workspace --no-auto-back-and-forth $ws_target;"
#      # move ws_target to op_current in case it was
#      # "assigned" to a different output. swapping 
#      # outputs is probably not what we want
#      msg+="[workspace=$ws_target] move workspace to output $op_current;"
#    fi
#    
#    # always focus ws_target
#    msg+="workspace --no-auto-back-and-forth $ws_target"
#    swaymsg "$msg"
#  '';
}
