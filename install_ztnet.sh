#!/usr/bin/env bash
# Automated installer for ZTNET docker-compose stack
set -euo pipefail

GREEN="\033[0;32m"
NC="\033[0m"

# 1. Check for dependencies
if ! command -v docker &>/dev/null || ! docker compose version &>/dev/null; then
  echo "Docker or Docker Compose not found."
  echo "Please run the 'initial-server-setup.sh' script first to install dependencies."
  exit 1
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
