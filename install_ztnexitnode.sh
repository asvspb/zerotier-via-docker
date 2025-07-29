#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker "$USER"
fi
if ! command -v docker compose &>/dev/null; then
  sudo apt-get update -qq && sudo apt-get install -y docker-compose-plugin
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/ztnexitnode"
[[ -f .env ]] || cp .env.example .env

echo "Edit ztnexitnode/.env with your ZT_NETWORK_ID before starting."
