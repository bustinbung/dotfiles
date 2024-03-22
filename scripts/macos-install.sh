# Install packages
echo ┌──────────────────────────────┐
echo │ Installing homebrew packages │
echo └──────────────────────────────┘
brew bundle install --no-lock --file=~/.local/share/chezmoi/packages/Brewfile
