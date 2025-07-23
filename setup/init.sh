#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Machine Setup Initialization ==="
echo

# Get current hostname as default
CURRENT_HOSTNAME=$(hostnamectl hostname)

# Prompt for hostname with current hostname as default
read -p "Enter hostname for this machine [$CURRENT_HOSTNAME]: " NEW_HOSTNAME

# Use current hostname if no input provided
if [[ -z "$NEW_HOSTNAME" ]]; then
    NEW_HOSTNAME="$CURRENT_HOSTNAME"
fi

# Set hostname
echo "Setting hostname to: $NEW_HOSTNAME"
sudo hostnamectl set-hostname "$NEW_HOSTNAME"
echo "127.0.1.1 $NEW_HOSTNAME" | sudo tee -a /etc/hosts

echo "Hostname set successfully!"
echo

# Execute setup scripts in correct order
echo "=== Starting setup process ==="
echo

echo "1. Installing packages..."
bash "$SCRIPT_DIR/install.sh"
echo

echo "2. Setting up Docker..."
bash "$SCRIPT_DIR/apps/docker.sh"
echo

echo "3. Configuring systemd power management..."
bash "$SCRIPT_DIR/systemd.sh"
echo

echo "4. Setting up terminal (Oh My Zsh)..."
bash "$SCRIPT_DIR/apps/z.sh"
echo

echo "5. Setting up dotfiles..."
bash "$SCRIPT_DIR/dotfile.sh"
echo

echo "6. Generating SSH credentials..."
bash "$SCRIPT_DIR/credential.sh"
echo

echo "=== Setup Complete! ==="
echo
echo "Summary:"
echo "- Hostname set to: $NEW_HOSTNAME"
echo "- Packages installed"
echo "- Docker configured"
echo "- Power management configured"
echo "- Terminal setup complete"
echo "- Dotfiles applied"
echo "- SSH key generated"
echo
echo "Note: You may need to reboot or log out/in for all changes to take effect."