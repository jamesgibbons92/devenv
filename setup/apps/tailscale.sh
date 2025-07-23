#!/bin/bash

set -e

echo "Setting up Tailscale and UFW firewall..."

# Enable and start Tailscale service
echo "Enabling and starting Tailscale service..."
sudo systemctl enable tailscaled
sudo systemctl start tailscaled

# Configure UFW firewall rules
echo "Configuring UFW firewall rules..."

# Reset UFW to defaults
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow all traffic through Tailscale interface
sudo ufw allow in on tailscale0

echo "UFW firewall configured with the following rules:"
echo "- Default: Deny all incoming, Allow all outgoing"
echo "- Allow all traffic through tailscale0 interface"
echo

echo "=== IMPORTANT: READ BEFORE PROCEEDING ==="
echo "1. You MUST login to Tailscale first: sudo tailscale up"
echo "2. Only after successful Tailscale login, enable UFW: sudo ufw enable"
echo "3. Failure to login to Tailscale before enabling UFW will lock you out!"
echo "4. Make sure you can access this machine through Tailscale before enabling UFW"
echo
echo "Tailscale setup complete - UFW configured but NOT enabled yet."