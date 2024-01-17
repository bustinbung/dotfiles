#!/usr/bin/env sh

LAYOUT=$(yabai -m query --spaces --space | jq '.type')

case $LAYOUT in
    "\"bsp\"") LABEL="bsp" ;;
    "\"float\"") LABEL="float" ;;
    "\"stack\"") LABEL="stack" ;;
    *) LABEL="ERR"
esac

sketchybar --set layout label="$LABEL"
