#!/bin/bash

set -e

update_official_packages() {
    echo "Updating official packages with pacman..."
    sudo pacman -Syu --noconfirm
}

update_aur_packages() {
    if command -v paru &> /dev/null; then
        echo "Updating AUR packages with paru..."
        paru -Sua
    else
        echo "paru not found, skipping AUR updates"
        echo "Run setup/install.sh first to install paru"
    fi
}

main() {
    echo "Starting system update..."
    
    update_official_packages
    update_aur_packages
    
    echo "System update complete!"
}

main "$@"