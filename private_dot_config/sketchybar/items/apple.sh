#!/bin/bash

POPUP_OFF='sketchybar --set apple.logo popup.drawing=off'
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

apple_logo=(
    padding_left=5
    padding_right=10

    align=center

    icon=$APPLE
    icon.font="$FONT:Regular:18.0"
    icon.padding_left=12
    icon.padding_right=12
    icon.y_offset=1

    popup.height=32
    popup.background.color=$BASE4
    popup.background.border_color=$BASE6
    popup.align=left

    background.border_width=2
    background.border_color=$BASE6
    background.color=$BASE4
    background.drawing=on

    label.drawing=off

    click_script="$POPUP_CLICK_SCRIPT"
)

apple_prefs=(
    icon=$PREFERENCES

    label="Preferences"
    label.align=right

    click_script="open -a 'System Preferences'; $POPUP_OFF"
)

apple_activity=(
    icon=$ACTIVITY

    label="Activity"
    label.align=right

    click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_lock=(
    icon=$LOCK

    label="Lock Screen"
    label.align=right

    click_script="pmset displaysleepnow; $POPUP_OFF"
)

sketchybar --add item apple.logo left                       \
           --set      apple.logo "${apple_logo[@]}"         \
                                                            \
           --add item apple.prefs popup.apple.logo          \
           --set      apple.prefs "${apple_prefs[@]}"       \
                                                            \
           --add item apple.activity popup.apple.logo       \
           --set      apple.activity "${apple_activity[@]}" \
                                                            \
           --add item apple.lock popup.apple.logo           \
           --set      apple.lock "${apple_lock[@]}"
