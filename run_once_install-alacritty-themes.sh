#!/usr/bin/env bash

if [[ ! -d ~/.config/alacritty/themes ]]; then
    mkdir -p ~/.config/alacritty/themes
    git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
fi
