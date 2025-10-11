#!/bin/bash

set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "⚠️  need sudo or to be root. Retry: sudo $0"
  exit 1
fi

pacman -Syu --noconfirm
pacman -S --noconfirm docker kubectl

systemctl enable --now docker.service
if ! getent group docker | grep -q "\b$SUDO_USER\b"; then
  usermod -aG docker "$SUDO_USER"
fi

if ! command -v k3d &> /dev/null; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi