#!/usr/bin/env bash

SPACES_LENGTH=$(yabai -m query --spaces | jq '. | length')

for ((i = 1; i <= SPACES_LENGTH; i++)); do
    sid=$i

    PAD_LEFT=2
    PAD_RIGHT=2
    if [[ $sid == 1 ]]; then
        PAD_LEFT=0
    elif [[ $sid == $SPACES_LENGTH ]]; then
        PAD_RIGHT=0
    fi

    space=(
        associated_space=$sid

        padding_left=$PAD_LEFT
        padding_right=$PAD_RIGHT

        background.color="$WHITE"
        background.border_width=2
        background.border_color="0x00FFFFFF"
        background.corner_radius=5
        background.height=28

        icon="$sid"
        icon.font="$FONT:Regular:12.0"
        icon.color="$SPACE_ICON"
        icon.highlight_color="$SPACE_ICON_HIGHLIGHT"
        icon.highlight=off
        icon.padding_left=8
        icon.padding_right=8

        label.drawing=off
        label.color="$SPACE_APP"
        label.highlight_color="$SPACE_APP_HIGHLIGHT"
        label.font="$APP_FONT:Regular:12.0"
        label.padding_left=0
        label.padding_right=8

        script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space space.$sid left                  \
               --set space.$sid "${space[@]}"               \
               --subscribe space.$sid space_windows_change  \
                                      space_change          \
                                      mouse.entered         \
                                      mouse.exited          \
                                      mouse.clicked
done

# sketchybar --add bracket spaces_bracket '/space\..*/' \
#            --set spaces_bracket background.color=$BASE4\
#                                 background.border_width=2\
#                                 background.border_color=$BASE6\
#                                 background.height=30

# separator=(
#     icon="$SPACE_SEPARATOR"
#     icon.font="FiraCode Nerd Font:Bold:16.0"
#     label.drawing=off
#     associated_display=active
# )

# sketchybar --add item separator left    \
#            --set      separator "${separator[@]}"
