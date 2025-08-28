#!/bin/bash

# Home dir dotfiles
mkdir -p ~/.config
stow -R -v -t ~ -d ~/.devenv/dot/base/home .

# Pacman config
sudo mkdir -p /etc/pacman.d/conf.d/
sudo stow -R -v -t /etc/pacman.d/conf.d/ -d ~/.devenv/dot/base/pacman .

# DE config
stow -R -v -t ~ -d ~/.devenv/dot/desktop .

# Add include line to pacman.conf if not already present
if ! grep -q "Include = /etc/pacman.d/conf.d/\*.conf" /etc/pacman.conf; then
    echo "Include = /etc/pacman.d/conf.d/*.conf" | sudo tee -a /etc/pacman.conf
fi
