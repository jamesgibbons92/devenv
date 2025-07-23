#!/bin/bash

# Check if Oh My Zsh is already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed, skipping..."
else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
