#!/bin/bash

LAYOUT=$(yabai -m query --spaces --space | jq '.type')

if [[ $1 == -r ]]; then
    case $LAYOUT in
        "\"bsp\"") yabai -m space --layout float ;;
        "\"float\"") yabai -m space --layout stack ;;
        "\"stack\"") yabai -m space --layout bsp && yabai -m space --mirror y-axis ;;
    esac
else
    case $LAYOUT in
        "\"bsp\"") yabai -m space --layout stack ;;
        "\"float\"") yabai -m space --layout bsp && yabai -m space --mirror y-axis ;;
        "\"stack\"") yabai -m space --layout float ;;
    esac
fi

sketchybar --trigger layout_change
