#!/bin/bash

set -e

echo "Setting up Docker..."

# Add current user to docker group
echo "Adding $USER to docker group..."
sudo usermod -aG docker $USER

# Enable and start docker service
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Enable and start docker socket
echo "Enabling and starting Docker socket..."
sudo systemctl enable docker.socket
sudo systemctl start docker.socket

echo "Docker setup complete!"
echo "Note: You may need to log out and back in for group changes to take effect."
echo "Or run: newgrp docker"