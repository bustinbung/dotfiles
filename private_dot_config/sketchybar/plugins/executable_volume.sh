#!/bin/sh

source "$CONFIG_DIR/icons.sh"

update () {
    VOLUME=$INFO

    case $VOLUME in
        [6-9][0-9]|100) ICON="$VOLUME_HIGH"
        ;;
        [3-5][0-9]) ICON="$VOLUME_MED"
        ;;
        [1-9]|[1-2][0-9]) ICON="$VOLUME_LOW"
        ;;
        *) ICON="$VOLUME_OFF"
    esac

    sketchybar --set $NAME icon="$ICON" label="$VOLUME%"
}

click() {
    CURRENT_WIDTH="$(sketchybar --query $NAME | jq -r .label.width)"

    WIDTH=0
    if [ "$CURRENT_WIDTH" -eq "0" ]; then
        WIDTH=dynamic
    fi

    sketchybar --animate sin 20 --set $NAME label.width="$WIDTH"
}

case "$SENDER" in
    "volume_change") update ;;
    "mouse.clicked") click ;;
esac
