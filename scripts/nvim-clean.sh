#!/bin/bash

set -e

echo "🧹 Cleaning Neovim installation..."

# Skip Neovim configuration directory (managed by dotfiles)
echo "Skipping Neovim config directory (managed by dotfiles): $HOME/.config/nvim"

# Remove Neovim data directory
if [ -d "$HOME/.local/share/nvim" ]; then
    echo "Removing Neovim data directory: $HOME/.local/share/nvim"
    rm -rf "$HOME/.local/share/nvim"
fi

# Remove Neovim state directory
if [ -d "$HOME/.local/state/nvim" ]; then
    echo "Removing Neovim state directory: $HOME/.local/state/nvim"
    rm -rf "$HOME/.local/state/nvim"
fi

# Remove Neovim cache directory
if [ -d "$HOME/.cache/nvim" ]; then
    echo "Removing Neovim cache directory: $HOME/.cache/nvim"
    rm -rf "$HOME/.cache/nvim"
fi

# Remove lazy.nvim plugin manager cache
if [ -d "$HOME/.local/share/lazy" ]; then
    echo "Removing lazy.nvim cache: $HOME/.local/share/lazy"
    rm -rf "$HOME/.local/share/lazy"
fi

# Remove packer.nvim plugin manager directory
if [ -d "$HOME/.local/share/nvim/site/pack/packer" ]; then
    echo "Removing packer.nvim directory: $HOME/.local/share/nvim/site/pack/packer"
    rm -rf "$HOME/.local/share/nvim/site/pack/packer"
fi

echo "✅ Neovim cleanup complete!"
echo "All configuration, data, cache, and plugin files have been removed."