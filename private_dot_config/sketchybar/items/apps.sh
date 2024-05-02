#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"

# item properties
app=(
    background.color="$ITEM_HIGHLIGHT"

    padding_left=0

    label.max_chars=25

    icon.padding_right=0

    label.color="$LABEL_HIGHLIGHT"
    icon.color="$LABEL_HIGHLIGHT"


    script="$PLUGIN_DIR/apps_plugin.sh"
)

sketchybar --add item  app left                 \
           --set       app "${app[@]}"          \
           --add event app_update               \
           --subscribe app front_app_switched   \
                           mouse.entered        \
                           mouse.exited         \
                           app_update
