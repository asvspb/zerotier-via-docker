#!/usr/bin/env bash
# remove_zerotier_stacks.sh ‑ remove all ZeroTier-related Docker stacks and images
# Usage: sudo ./remove_zerotier_stacks.sh  OR  ./remove_zerotier_stacks.sh (if user in docker group)
#
# This helper stops & deletes containers, networks, and volumes that belong to the
# following repository stacks:
#   • ztnexitnode/
#   • ztnet/
#   • ztncui/
# It also prunes dangling images afterwards.  Native ZeroTier packages are **not**
# touched because the project uses containerised ZeroTier only.

set -euo pipefail
IFS=$'\n\t'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKS=("ztnexitnode" "ztnet" "ztncui")

for stack in "${STACKS[@]}"; do
  COMPOSE_DIR="$REPO_ROOT/$stack"
  if [[ -f "$COMPOSE_DIR/docker-compose.yml" ]]; then
    echo "==== Stopping & removing stack: $stack ===="
    (cd "$COMPOSE_DIR" && docker compose down -v --remove-orphans) || true
  fi
done

echo "==== Removing ZeroTier-related images ===="
# list images whose repository contains "zerotier" or "ztn" (to catch ztncui, ztnet)
IMAGE_IDS=$(docker images --format '{{.Repository}} {{.ID}}' | awk '/(zerotier|ztn)/{print $2}')
if [[ -n "$IMAGE_IDS" ]]; then
  docker rmi -f $IMAGE_IDS || true
else
  echo "No ZeroTier images found."
fi

echo "==== Pruning dangling images & volumes ===="
docker image prune -f
# optional: docker volume prune -f

echo "Cleanup complete."