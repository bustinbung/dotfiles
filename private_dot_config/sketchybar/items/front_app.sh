#!/bin/bash

FRONT_APP_SCRIPT='[ "$SENDER" = "front_app_switched" ] && sketchybar --set $NAME label="$INFO"'

front_app=(
    icon.drawing=off
    label.font="$FONT:Semibold:14.0"
    y_offset=-1
    associated_display=active
    script="$FRONT_APP_SCRIPT"
)

sketchybar --add item   front_app left                \
           --set        front_app "${front_app[@]}"   \
           --subscribe  front_app front_app_switched
