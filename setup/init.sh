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

# Prompt for environment type
echo "Select environment type:"
echo "1) Home"
echo "2) Work"
read -p "Enter choice (1 or 2): " ENV_CHOICE

case $ENV_CHOICE in
    1)
        ENV_TYPE="home"
        echo "Selected: Home environment"
        ;;
    2)
        ENV_TYPE="work"
        echo "Selected: Work environment"
        ;;
    *)
        echo "Invalid choice. Skipping"
    ;;
esac
echo

# Execute setup scripts in correct order
echo "=== Starting setup process ==="
echo

echo "1. Installing packages..."
bash "$SCRIPT_DIR/install.sh" "$ENV_TYPE"
echo

echo "2. Enabling services..."
for service_script in "$SCRIPT_DIR/services"/*.sh; do
    if [[ -f "$service_script" ]]; then
        echo "Running $(basename "$service_script")..."
        bash "$service_script"
    fi
done
echo


echo "2. Setting up dotfiles..."
bash "$SCRIPT_DIR/dotfile.sh"
echo

echo "3. Generating SSH credentials..."
bash "$SCRIPT_DIR/credential.sh"
echo

echo "=== Setup Complete! ==="
echo
echo "Summary:"
echo "- Hostname set to: $NEW_HOSTNAME"
echo "- Packages installed"
echo "- SSH key generated"
echo
echo "Note: You may need to reboot or log out/in for all changes to take effect."
