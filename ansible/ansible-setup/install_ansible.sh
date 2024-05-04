#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Check if running with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo" >&2
    exit 1
fi

# Update system packages
apt update -y && apt upgrade -y || { echo "Failed to update system packages"; exit 1; }

# Install Python 3 and pip
apt install -y python3 python3-pip || { echo "Failed to install Python 3 and pip"; exit 1; }

# Install Ansible with pip
pip3 install ansible || { echo "Failed to install Ansible"; exit 1; }

# Add ~/.local/bin to PATH if not already present
if ! grep -qxF 'export PATH="$PATH:$HOME/.local/bin"' "$HOME/.bashrc"; then
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc" || { echo "Failed to reload ~/.bashrc"; exit 1; }
fi


sudo hostnamectl set-hostname ansible-controller

bash

echo "Script completed successfully"


########## END  ############

