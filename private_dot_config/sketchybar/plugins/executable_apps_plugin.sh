#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/colors.sh"

mouse() {
    if [[ "$SENDER" == "mouse.entered" ]]; then
        sketchybar --set app scroll_texts=on
    else
        sketchybar --set app scroll_texts=off
    fi
}

update() {
    APP=$(yabai -m query --windows --window)

    if [ ! -z "$APP" ]; then
        APP_NAME=$(jq '.app' <<< "$APP" | tr -d '"')
        APP_TITLE=$(jq '.title' <<< "$APP" | tr -d '"' | xargs echo)
        __icon_map "${APP_NAME}"
        ICON="${icon_result}"

        app=(
            drawing=on

            icon.font="sketchybar-app-font:Regular:12"
            icon="$ICON"
        )

        if [ "$APP_NAME" == "$APP_TITLE" ]; then
            app+=(label="$APP_NAME")
        else
            app+=(label="$APP_NAME / $APP_TITLE")
        fi

        if $(jq '."is-floating"' <<< "$APP"); then
            app+=(background.border_color="$SPACE_NATIVE_FULLSCREEN")
        else
            app+=(background.border_color="0x00ffffff")
        fi
    else
        app=(
            drawing=off
        )
    fi

    sketchybar --set app "${app[@]}"
}

case "$SENDER" in
    "mouse.entered" | "mouse.exited") mouse ;;
    *) update ;;
esac
