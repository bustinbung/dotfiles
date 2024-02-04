#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"

# get total number of spaces
SPACES_LENGTH=$(yabai -m query --spaces | jq '. | length')

# create item for each space
for ((i = 1; i <= SPACES_LENGTH; i++)); do
    # set padding for all spaces
    PAD_LEFT=2
    PAD_RIGHT=2

    # if first space...
    if [[ $i == 1 ]]; then
        PAD_LEFT=0
    fi

    # if last space...
    if [[ $i == $SPACES_LENGTH ]]; then
        PAD_RIGHT=0
    fi

    # set space properties
    space=(
        associated_space=$i

        padding_left="$PAD_LEFT"
        padding_right="$PAD_RIGHT"

        icon="$i"

        label.drawing=off
        label.padding_left=0

        script="$PLUGIN_DIR/spaces_plugin.sh"
    )

    sketchybar --add event space_created                    \
               --add event space_destroyed                  \
               --add space space.$i left                    \
               --set space.$i "${space[@]}"                 \
               --subscribe space.$i space_windows_change    \
                                    space_change            \
                                    space_created           \
                                    space_destroyed         \
                                    mouse.entered           \
                                    mouse.exited            \
                                    mouse.clicked
done
