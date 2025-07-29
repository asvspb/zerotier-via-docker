#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# === PARAMETERS ==========================================================
TARGET_USER=""
TIMEZONE="Europe/London"
NODE_LTS="lts/*"      # e.g. "20" to pin a version
PG_VERSION=15
# ========================================================================

usage() {
  echo "Usage: sudo bash $0 --user <username> [--no-zsh] [--no-tmux]"
  exit 1
}

# --- parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) TARGET_USER="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option $1"; usage ;;
  esac
done

[[ -z "$TARGET_USER" ]] && { echo "ERROR: --user is required"; exit 2; }
id "$TARGET_USER" &>/dev/null || { echo "ERROR: user $TARGET_USER does not exist"; exit 3; }

echo "=== Updating system ==="
apt-get update -y && apt-get upgrade -y

echo "=== Installing base packages ==="
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential curl wget git unzip zip htop mc \
  software-properties-common ca-certificates gnupg lsb-release \
  ufw fail2ban jq locales tzdata python3 python3-pip python3-venv

echo "=== Timezone and locale ==="
timedatectl set-timezone "$TIMEZONE"
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

echo "=== Docker ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu jammy stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker "$TARGET_USER"
systemctl enable docker

echo "=== Docker Compose ==="
if ! command -v docker compose &>/dev/null; then
  apt-get install -y docker-compose-plugin
else
  echo "Docker Compose is already installed."
fi

echo "=== Node.js ==="
curl -fsSL https://deb.nodesource.com/setup_"$NODE_LTS".x |
  bash - && apt-get install -y nodejs

  
echo "=== UFW and Fail2ban ==="
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable
cat >/etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
EOF
systemctl enable fail2ban --now
