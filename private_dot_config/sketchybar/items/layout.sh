#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

layout=(
    background.color="$ITEM_SECONDARY_COLOR"

    icon.drawing=off

    label.color=0xFFFFFFFF

    associated_display=active

    script="$PLUGIN_DIR/layout_plugin.sh"
)

sketchybar --add event layout_change            \
           --add item  layout left              \
           --set       layout "${layout[@]}"    \
           --subscribe layout layout_change     \
                              space_change
