#!/usr/bin/env bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

APP_FONT="app-font"

update() {
    sketchybar --set $NAME icon.highlight=$SELECTED     \
                           label.highlight=$SELECTED

    if $SELECTED; then
        sketchybar --set $NAME background.color="$SPACE_SELECTED"
    else
        sketchybar --set $NAME background.color="$SPACE"
    fi

    SPACES_LENGTH=$(yabai -m query --spaces | jq '. | length')

    for ((i = 1; i <= SPACES_LENGTH; i++)); do
        sid=$i
        LABEL=""

        if $(yabai -m query --spaces --space $sid | jq '."is-native-fullscreen" == true'); then
            sketchybar --set space.$sid background.color="$SPACE_NATIVE_FULLSCREEN"  \
                       --set space.$sid icon.color="$SPACE"
        fi

        APPS=$(yabai -m query --windows --space $sid)
        APPS_LENGTH=$(jq '. | length' <<< $APPS)

        if ((APPS_LENGTH == 0)); then
            space=(
                label.drawing=off
            )

            sketchybar --set space.$sid "${space[@]}"
            continue
        fi

        for ((j = 0; j < APPS_LENGTH; j++)); do
            APP=$(jq '. | nth('$j')' <<< $APPS)

            IS_APP_HIDDEN=$(jq '."is-hidden" == true' <<< $APP)
            IS_APP_MINIMIZED=$(jq '."is-minimized" == true' <<< $APP)

            if [[ $IS_APP_HIDDEN == true ]] || [[ $IS_APP_MINIMIZED == true ]]; then
                continue
            fi

            APP_NAME=$(echo $APP | jq '.app' | tr -d '"')
            APP_ICON=$(icon_map $APP_NAME)

            LABEL+="$APP_ICON"

            if ((j < APPS_LENGTH)); then
                LABEL+=" "
            fi
        done

        space=(
            label="$LABEL"
            label.font="$APP_FONT:Regular:12"
            label.drawing=on
        )

        sketchybar --set space.$sid "${space[@]}"
    done
}

mouse_clicked() {
    yabai -m space --focus $SID
    sketchybar --trigger space_change
}

mouse_entered() {
    sketchybar --animate sin 15 --set $SENDER background.border_color="$SPACE_BORDER"
}

mouse_exited() {
    sketchybar --animate sin 15 --set $SENDER background.border_color="0x00FFFFFF"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  "mouse.entered") mouse_entered ;;
  "mouse.exited") mouse_exited ;;
  *) update ;;
esac
