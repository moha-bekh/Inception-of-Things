#!/bin/bash

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "Need root privileges. Retry with:"
    echo "sudo $0"
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "This script is intended for Arch Linux."
    exit 1
fi

echo "Installing required packages..."

pacman -Sy --noconfirm
pacman -S --noconfirm \
    curl \
    docker \
    kubectl \
    helm \
    git

echo "Starting Docker..."
systemctl enable --now docker.service

TARGET_USER="${SUDO_USER:-}"

if [[ -n "$TARGET_USER" ]]; then
    if ! id -nG "$TARGET_USER" | grep -qw docker; then
        usermod -aG docker "$TARGET_USER"
        echo "Added '$TARGET_USER' to the docker group."
        echo "Please log out and back in (or restart your shell) before running build.sh."
    fi
fi

if ! command -v k3d >/dev/null 2>&1; then
    echo "Installing k3d..."
    curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "k3d is already installed."
fi

echo "Installation completed successfully."