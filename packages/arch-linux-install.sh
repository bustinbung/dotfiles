# Install arch packages
echo ┌──────────────────────────┐
echo │ Installing Arch packages │
echo └──────────────────────────┘
sudo pacman -S --noconfirm --needed - < $HOME/.local/share/chezmoi/packages/arch-pkglist

# Install AUR packages
echo ┌─────────────────────────┐
echo │ Installing AUR packages │
echo └─────────────────────────┘
yay -S --noconfirm --needed - < $HOME/.local/share/chezmoi/packages/aur-pkglist

# Fix suspend issues
if [ ! -e /etc/tmpfiles.d/fix-suspend.conf ] ; then
  echo ┌─────────────────────────────┐
  echo │ Writing suspend fix tmpfile │
  echo └─────────────────────────────┘
  echo w /proc/acpi/wakeup - - - - GPP0 | sudo tee /etc/tmpfiles.d/fix-suspend.conf

  echo ┌────────────────────────────────┐
  echo │ Enabling Nvidia power services │
  echo └────────────────────────────────┘
  sudo systemctl enable nvidia-{suspend,hibernate,resume}
fi

# Install doom emacs
if [ ! -d $HOME/.config/emacs ] ; then
  echo ┌───────────────────────┐
  echo │ Installing Doom Emacs │
  echo └───────────────────────┘
  git clone --depth 1 git@github.com:doomemacs/doomemacs $HOME/.config/emacs
  $HOME/.config/emacs/bin/doom install --force --config --env --install --fonts
fi

# Install SDKMAN
if [ ! -d $HOME/.sdkman ] ; then
  echo ┌───────────────────┐
  echo │ Installing SDKMAN │
  echo └───────────────────┘
  curl -s "https://get.sdkman.io" | bash
  source $HOME/.sdkman/bin/sdkman-init.sh

  sdk install java
  sdk install java 17.0.10-oracle
fi

# Change user shell
if [ ! $SHELL = $(which zsh) ] ; then
  echo ┌───────────────────────┐
  echo │ Changing shell to zsh │
  echo └───────────────────────┘
  sudo chsh -s $(which zsh) $(whoami)
fi
