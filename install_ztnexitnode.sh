#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker &>/dev/null || ! docker compose version &>/dev/null; then
  echo "Docker or Docker Compose not found."
  echo "Please run the 'initial-server-setup.sh' script first to install dependencies."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/ztnexitnode"
[[ -f .env ]] || cp .env.example .env

echo "Edit ztnexitnode/.env with your ZT_NETWORK_ID before starting."
echo "Once edited, you can run 'docker compose up -d' inside the 'ztnexitnode' directory."
