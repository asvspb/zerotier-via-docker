#!/usr/bin/env bash
# Automated installer for ZTNET docker-compose stack
set -euo pipefail

GREEN="\033[0;32m"
NC="\033[0m"

# 1. Install docker & compose if missing
if ! command -v docker &>/dev/null; then
  echo -e "${GREEN}[+] Installing Docker …${NC}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker "$USER"
  echo "Docker installed. Log out/in for group changes to take effect."  
fi

if ! command -v docker compose &>/dev/null; then
  echo -e "${GREEN}[+] Installing docker-compose plugin …${NC}"
  sudo apt-get update -qq && sudo apt-get install -y docker-compose-plugin
fi

# 2. Prepare project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZTNET_DIR="$SCRIPT_DIR/ztnet"
cd "$ZTNET_DIR"

# 3. Copy .env
if [[ -f .env ]]; then
  echo ".env already exists, skipping copy."
else
  cp .env.example .env
  echo "Created .env from template. Edit it to suit your environment (especially NEXTAUTH_URL & secrets)."
fi

# 4. Optionally set NEXTAUTH_URL to server IP automatically
read -rp "Auto-set NEXTAUTH_URL to this server's IP? [y/N]: " AUTO_IP
if [[ "$AUTO_IP" =~ ^[Yy]$ ]]; then
  IP=$(hostname -I | cut -d' ' -f1)
  sed -i "s|NEXTAUTH_URL=.*|NEXTAUTH_URL=http://$IP:3000|" .env
  echo "NEXTAUTH_URL set to http://$IP:3000"
fi

# 5. Launch stack
echo -e "${GREEN}[+] Pulling images and starting containers …${NC}"
docker compose pull
docker compose up -d

echo -e "${GREEN}ZTNET is now running. Visit the URL configured in .env (default http://<ip>:3000).${NC}"
