#!/bin/bash

update() {
    source "$CONFIG_DIR/icons.sh"
    INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F ' SSID: '  '/ SSID: / {print $2}')"
    SSID="$([ -n "$INFO" ] && echo $INFO || echo "Disconnected")"
    ICON="$([ -n "$INFO" ] && echo "$WIFI_CONNECTED" || echo "$WIFI_DISCONNECTED")"

    sketchybar --set $NAME icon="$ICON" label=$SSID
}

case "$SENDER" in
    "wifi_change") update ;;
esac
