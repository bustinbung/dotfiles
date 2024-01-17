#!/bin/bash

source "$CONFIG_DIR/icons.sh"

volume=(
    label.width=0
    script="$PLUGIN_DIR/volume.sh"
)

sketchybar --add item  volume right             \
           --set       volume "${volume[@]}"    \
           --subscribe volume volume_change     \
                              mouse.clicked
