k#!/bin/bash

TERMINAL="kitty"
CLASS="dropdownterm"

# Check if dropdown terminal exists
wid=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$CLASS\") | .address")

if [ -z "$wid" ]; then
    # Not running — spawn it
    $TERMINAL --class $CLASS &
    exit
fi

# Check if it's visible (mapped)
mapped=$(hyprctl clients -j | jq -r ".[] | select(.class==\"$CLASS\") | .mapped")

if [ "$mapped" = "true" ]; then
    # Window is visible, hide it by setting it invisible (send to background layer)
    hyprctl dispatch movetoworkspacesilent special silent address:$wid
else
    # Window is hidden, bring it back
    hyprctl dispatch bringwindowfront address:$wid
fi

