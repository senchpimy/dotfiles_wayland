#!/bin/bash

device=$(upower -d | grep -i "headset" -C 3)

if [[ -n "$device" ]]; then
    percentage=$(echo "$device" | grep -i "percentage" | awk '{print $2}'  | sed 's/%//')
    echo "$percentage headphones"
fi

laptop=$(upower -i `upower -e | grep 'BAT'`)

if [[ -n "$laptop" ]]; then
  value=$( echo "$laptop" | grep  -i "percentage" | sed 's/[^0-9]*\([0-9]\+\).*/\1/')
  state=$( echo "$laptop" | grep  -i "state" |awk '{print $2}')
  echo "$value laptop $state"
fi
