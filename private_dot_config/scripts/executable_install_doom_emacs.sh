#!/bin/bash

# install emacs-plus
brew tap d12frosted/emacs-plus
brew install --cask emacs-plus-app

# install doom
brew install git ripgrep coreutils findutils gnu-tar ispell
if [ -d ~/.config/emacs ]; then
  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
fi
~/.config/emacs/bin/doom install --aot --env --install --no-config
