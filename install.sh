#!/usr/bin/env bash

echo "Cloning repository"
git clone https://github.com/janpstrunn/pass-rofi
cd pass-rofi

# Install the main script
chmod 700 src/pass-rofi
mv src/pass-rofi "$HOME/.local/bin/" && echo "Moved script to $HOME/.local/bin/"

echo "Installation complete. Restart your shell or run 'exec bash'/'exec zsh' to apply changes."
