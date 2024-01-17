#!/bin/bash

source "$CONFIG_DIR/icons.sh"

clock=(
    icon.drawing=off
    icon.padding_left=0
    icon.padding_right=0
    label.padding_left=0
    update_freq=10
    script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right       \
           --set      clock "${clock[@]}"
