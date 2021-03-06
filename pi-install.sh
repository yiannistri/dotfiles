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
sudo systemctl enable docker
# Docker Compose
sudo pip3 -v install docker-compose
# Pi-hole
docker-compose -f ./config/pi-hole.yaml up --detach
# Home Assistant
docker-compose -f ./config/homeassistant/docker-compose.yaml up --detach

sudo apt -y autoremove