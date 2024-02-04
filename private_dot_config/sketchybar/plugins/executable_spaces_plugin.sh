#!/usr/bin/env bash

# source colors, icons, and icon map plugin
source "$CONFIG_DIR/colors.sh"

PLUGIN_DIR="$CONFIG_DIR/plugins"
source "$PLUGIN_DIR/icon_map.sh"

# set app icon font
APP_FONT="app-font:Regular:12.0"

update() {
    # set icon and label color if selected
    sketchybar --set "$NAME" icon.highlight="$SELECTED" \
                           label.highlight="$SELECTED"

    # set background color if selected
    if "$SELECTED"; then
        sketchybar --animate sin 10 --set "$NAME" background.color="$ITEM_HIGHLIGHT"
    else
        sketchybar --animate sin 10 --set "$NAME" background.color="$ITEM_COLOR"
    fi

    # pull all spaces
    SPACES=$(yabai -m query --spaces)
    SPACES_LENGTH=$(jq '. | length' <<< "$SPACES")

    # run following block for every space
    for ((i = 0; i < SPACES_LENGTH; i++)); do
        # set sid. we need both i and sid for indexing into the $SPACES variable
        sid=$(( i + 1 ))

        # set color if space is in native fullscreen
        if $(jq '.['$i']."is-native-fullscreen" == true' <<< "$SPACES"); then
            sketchybar --set space.$sid background.color="$SPACE_NATIVE_FULLSCREEN"   \
                       --set space.$sid icon.color="$ITEM_COLOR"
        fi

        # pull all apps in current space
        APPS=$(yabai -m query --windows --space $sid)
        APPS_LENGTH=$(jq '. | length' <<< "$APPS")

        # continue if there are no apps in the space
        if (( APPS_LENGTH == 0 )); then
            sketchybar --set space.$sid label.drawing=off
            continue
        fi

        # initialize empty label
        LABEL=""

        # loop through all apps
        for ((j = 0; j < APPS_LENGTH; j++)); do
            # get current app
            CURRENT_APP=$(jq '.['$j']' <<< "$APPS")

            # if app is hidden or minimized, continue and don't show in label
            IS_HIDDEN=$(jq '."is-hidden" == true' <<< "$CURRENT_APP")
            # IS_MINIMIZED=$(jq '."is-minimized" == true' <<< "$CURRENT_APP")

            # if $IS_HIDDEN || $IS_MINIMIZED; then
            if $IS_HIDDEN; then
                continue
            fi

            # get app name and icon
            APP_NAME=$(jq '.app' <<< "$CURRENT_APP" | tr -d '"')
            APP_ICON=$(icon_map "$APP_NAME")

            # append icon to label
            LABEL+="$APP_ICON"

            # add space between icons if not last icon
            if ((j < APPS_LENGTH)); then
                LABEL+=" "
            fi
        done

        # set space label and font. if we made it this far, we can assume that the label is not empty
        space=(
            label="$LABEL"
            label.drawing=on

            label.font="$APP_FONT"
        )

        sketchybar --set space.$sid "${space[@]}"
    done
}

# switch to space if clicked
mouse_clicked() {
    yabai -m space --focus "$SID"
    sketchybar --trigger space_change
    sketchybar --animate sin 10 --set "$NAME" background.border_color="0x00FFFFFF"
}

mouse_entered() {
    if $SELECTED; then
        return;
    fi

    sketchybar --animate sin 10 --set "$NAME" background.border_color="$BORDER"
}

mouse_exited() {
    if $SELECTED; then
        return;
    fi

    sketchybar --animate sin 10 --set "$NAME" background.border_color="0x00FFFFFF"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") mouse_entered ;;
  "mouse.exited") mouse_exited ;;
  *) update ;;
esac
