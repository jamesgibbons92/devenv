#!/bin/bash

USER=$(whoami)
HOSTNAME=$(hostnamectl hostname)
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if SSH key already exists
if [ -f "$SSH_KEY_PATH" ]; then
  echo "SSH key already exists at $SSH_KEY_PATH"
  exit 0
fi

# Create .ssh directory if it doesn't exist
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Generate SSH key
echo "Generating SSH key: $SSH_KEY_PATH"
ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "${USER}@${HOSTNAME}" -N ""

# Set proper permissions
chmod 600 "$SSH_KEY_PATH"
chmod 644 "${SSH_KEY_PATH}.pub"

echo "SSH key generated successfully!"
echo "Public key location: ${SSH_KEY_PATH}.pub"
echo "Private key location: $SSH_KEY_PATH"
