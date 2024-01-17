#!/bin/bash

source "$CONFIG_DIR/colors.sh"

layout=(
    script="$PLUGIN_DIR/layout.sh"

    background.color="$LAYOUT_BACKGROUND"
    background.corner_radius=5
    background.height=28

    icon.drawing=off

    label="bsp"
    label.font="$FONT:Regular:12"
    label.color=0xFFFFFFFF

    associated_display=active
)

sketchybar --add event layout_change             \
           --add item  layout left               \
           --set       layout "${layout[@]}"      \
           --subscribe layout layout_change     \
                              space_change
