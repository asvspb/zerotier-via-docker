#!/usr/bin/env bash

# Helper script to install Docker Engine and the docker-compose plugin on Ubuntu/Debian.
# Additionally generates an .env template for the exitnode stack.
set -euo pipefail

info() { echo -e "\033[0;32m[+] $*\033[0m"; }
warn() { echo -e "\033[0;33m[!] $*\033[0m"; }

# 1. Install Docker Engine if absent
if ! command -v docker &>/dev/null; then
  info "Installing Docker Engine …"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker "$USER" || true
  warn "Log out/in or run 'newgrp docker' to apply group changes."
else
  info "Docker is already installed."
fi

# 2. Install docker-compose plugin if absent
if ! command -v docker compose &>/dev/null; then
  info "Installing docker-compose plugin …"
  sudo apt-get update -qq && sudo apt-get install -y docker-compose-plugin
else
  info "docker-compose plugin is already present."
fi

# 3. Create .env template for the exitnode stack
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"
if [[ ! -f .env ]]; then
  read -rp "Enter your 16-digit ZT_NETWORK_ID: " ZT_NETWORK_ID
  cat >.env <<EOF
ZT_NETWORK_ID=${ZT_NETWORK_ID}
ZT_TOKEN=
ZT_NODE_NAME=
EOF
  info ".env template created. Edit it to add a ZeroTier API token or node name if required."
else
  info ".env already exists – skipping creation."
fi

cat <<EONOTE

Docker installation complete.
Next steps to start the exit-node stack:
  cd exitnode
  docker compose up -d --build

To follow logs:
  docker compose logs -f zerotier
EONOTE
