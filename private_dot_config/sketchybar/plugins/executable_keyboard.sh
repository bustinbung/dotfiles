#!/bin/bash

LAYOUT="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep "KeyboardLayout Name" | cut -c 33- | rev | cut -c 2- | rev)"

case "$LAYOUT" in
    "Dvorak") SHORT_LAYOUT="DV";;
    "\"U.S.\"") SHORT_LAYOUT="US";;
    *) SHORT_LAYOUT="한";;
esac

sketchybar --set keyboard label="$SHORT_LAYOUT"
