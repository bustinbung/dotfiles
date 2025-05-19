#!/bin/bash

LAYOUT=$(yabai -m query --spaces --space | jq '.type')

case $LAYOUT in
    "\"bsp\"") yabai -m space --layout stack ;;
    "\"stack\"") yabai -m space --layout bsp ;;
    *) yabai -m space --layout stack
esac
