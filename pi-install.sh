#!/bin/bash
set -euo pipefail

sudo apt update && sudo apt upgrade
sudo apt dist-upgrade

# Remote desktop
sudo apt install xrdp
# SSH
sudo systemctl enable ssh
sudo systemctl start ssh
# Docker
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $(whoami)