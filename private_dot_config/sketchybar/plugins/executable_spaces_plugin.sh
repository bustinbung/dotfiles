#!/usr/bin/env bash

# source colors, icons, and icon map plugin
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

# set app icon font
APP_FONT="sketchybar-app-font:Regular:12.0"

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

space_windows_change() {
    sid=$(grep -Eo "[0-9]*" <<< "$NAME")

    # pull all apps in current space
    APPS=$(yabai -m query --windows --space "$sid")
    APPS_LENGTH=$(jq '. | length' <<< "$APPS")

    # continue if there are no apps in the space
    if (( APPS_LENGTH == 0 )); then
        sketchybar --set space."$sid" label.drawing=off
        return
    fi

    # initialize empty label
    LABEL=""

    # loop through all apps
    for ((i = 0; i < APPS_LENGTH; i++)); do
        # get current app
        CURRENT_APP=$(jq '.['$i']' <<< "$APPS")

        # if app is hidden or minimized, continue and don't show in label
        IS_HIDDEN=$(jq '."is-hidden" == true' <<< "$CURRENT_APP")
        # IS_MINIMIZED=$(jq '."is-minimized" == true' <<< "$CURRENT_APP")

        # if $IS_HIDDEN || $IS_MINIMIZED; then
        if $IS_HIDDEN; then
            continue
        fi

        # get app name and icon
        APP_NAME=$(jq '.app' <<< "$CURRENT_APP" | tr -d '"')
        __icon_map "${APP_NAME}"
        APP_ICON="${icon_result}"

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

    sketchybar --set space."$sid" "${space[@]}"
}

space_update() {
    # set icon and label color if selected
    sketchybar --set "$NAME" icon.highlight="$SELECTED" \
                           label.highlight="$SELECTED"

    sid=$(grep -Eo "[0-9]*" <<< "$NAME")
    i=$((sid - 1))
    SPACES=$(yabai -m query --spaces)

    # set color if space is in native fullscreen
    if $(jq '.['$i']."is-native-fullscreen" == true' <<< "$SPACES"); then
        sketchybar --set space."$sid" background.color="$SPACE_NATIVE_FULLSCREEN"   \
            --set space."$sid" icon.color="$ITEM_COLOR"
    fi

    # set background color if selected
    if "$SELECTED"; then
        sketchybar --animate sin 10 --set "$NAME" background.color="$ITEM_HIGHLIGHT"
    else
        sketchybar --animate sin 10 --set "$NAME" background.color="$ITEM_COLOR"
    fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") mouse_entered ;;
  "mouse.exited") mouse_exited ;;
  "space_windows_change") space_windows_change ;;
  "space_change" | "space_created" | "space_destroyed") space_update ;;
esac
