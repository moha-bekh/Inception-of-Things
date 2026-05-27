#!/bin/bash

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Need sudo or root. Retry: sudo $0"
  exit 1
fi

if ! command -v pacman &> /dev/null; then
  echo "This install script expects an Arch-based VM with pacman."
  exit 1
fi

pacman -Syu --noconfirm
pacman -S --noconfirm curl docker kubectl

systemctl enable --now docker.service

TARGET_USER="${SUDO_USER:-}"
if [[ -n "$TARGET_USER" ]] && ! getent group docker | grep -q "\b$TARGET_USER\b"; then
  usermod -aG docker "$TARGET_USER"
  echo "User '$TARGET_USER' was added to the docker group. Reopen the shell if docker is still denied."
fi

if ! command -v k3d &> /dev/null; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi
