#!/bin/bash
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do 
  if [[ $line == activewindow* ]]; then
    IS_FLOATING=$(hyprctl activewindow -j | jq '.floating')
    if [[ "$IS_FLOATING" == "true" ]]; then
        hyprctl dispatch bringactivetotop
    fi
  fi
done
