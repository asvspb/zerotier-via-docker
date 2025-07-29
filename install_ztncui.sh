#!/usr/bin/env bash
# Automated installer for ztncui (all-in-one ZeroTier controller UI)
set -euo pipefail

GREEN="\033[0;32m"; NC="\033[0m"

if ! command -v docker &>/dev/null; then
  echo -e "${GREEN}[+] Installing Docker…${NC}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker "$USER"
  echo "Relogin required for docker group changes."
fi
if ! command -v docker compose &>/dev/null; then
  echo -e "${GREEN}[+] Installing docker-compose plugin…${NC}"
  sudo apt-get update -qq && sudo apt-get install -y docker-compose-plugin
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZC_DIR="$SCRIPT_DIR/ztncui"
cd "$ZC_DIR"

# Copy env template if not exist
[[ -f .env ]] || { cp .env.example .env; echo "Created .env from template. Edit MYADDR and password."; }

read -rp "Auto-detect public IP and set MYADDR? [y/N]: " A
if [[ "$A" =~ ^[Yy]$ ]]; then
  PUB=$(curl -s https://ifconfig.me || echo "")
  if [[ -n "$PUB" ]]; then sed -i "s/^MYADDR=.*/MYADDR=$PUB/" .env; echo "MYADDR set to $PUB"; fi
fi

echo -e "${GREEN}[+] Running docker compose up -d …${NC}"
docker compose pull
docker compose up -d

echo -e "${GREEN}ztncui is available on port 3443 (HTTPS) or 3180/HTTP file server.${NC}"
