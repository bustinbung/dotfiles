#!/usr/bin/env bash

case $(yabai -m query --spaces --space | jq '.type') in
    "\"bsp\"") LABEL="bsp" ;;
    "\"float\"") LABEL="float" ;;
    "\"stack\"") LABEL="stack" ;;
    *) LABEL="ERR"
esac

sketchybar --set layout label="$LABEL"
