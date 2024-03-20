#!/usr/bin/env bash
# Install arch packages
sudo pacman -S --noconfirm --needed - < arch-pkglist

# Install AUR packages
yay -S --noconfirm --needed - < aur-pkglist

# Fix suspend issues
if [ ! -e /etc/tmpfiles.d/fix-suspend.conf ] ; then
  echo w /proc/acpi/wakeup - - - - GPP0 | sudo tee /etc/tmpfiles.d/fix-suspend.conf
fi
sudo systemctl enable nvidia-{suspend,hibernate,resume}

# Install doom emacs
if [ ! -d $HOME/.config/emacs ] ; then
  git clone --depth 1 git@github.com:doomemacs/doomemacs $HOME/.config/emacs
  $HOME/.config/emacs/bin/doom install --force --config --env --install --fonts
fi

# Install SDKMAN
if [ ! -d $HOME/.sdkman ] ; then
  curl -s "https://get.sdkman.io" | bash
  source $HOME/.sdkman/bin/sdkman-init.sh

  sdk install java
  sdk install java 17.0.10-oracle
fi

# Change user shell
if [ ! $SHELL = $(which zsh) ] ; then
  sudo chsh -s $(which zsh) $(whoami)
fi
