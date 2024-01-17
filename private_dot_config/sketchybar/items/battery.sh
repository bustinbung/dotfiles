#!/bin/bash

battery=(
    update_freq=120
    width=dynamic
    script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item  battery right                \
           --set       battery "${battery[@]}"      \
           --subscribe battery system_woke          \
                               power_source_change  \
                               mouse.clicked
