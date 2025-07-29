#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# === PARAMETERS ==========================================================
TARGET_USER=""
TIMEZONE="Europe/London"
NODE_LTS="20" # e.g. "20" to pin a version
# ========================================================================

usage() {
  echo "Usage: sudo bash $0 --user <username> [--timezone <tz>]"
  echo "  --user <username>: (Required) The non-root user to configure."
  echo "  --timezone <tz>:   Set the server timezone (default: Europe/London)."
  exit 1
}

# --- parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --user)     TARGET_USER="$2"; shift 2 ;;
    --timezone) TIMEZONE="$2"; shift 2 ;;
    -h|--help)  usage ;;
    *)          echo "Unknown option $1"; usage ;;
  esac
done

[[ $EUID -ne 0 ]] && { echo "ERROR: This script must be run as root."; exit 1; }
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
echo "Adding user $TARGET_USER to docker group..."
usermod -aG docker "$TARGET_USER" || echo "Warning: could not add $TARGET_USER to docker group."
systemctl enable --now docker

echo "=== Node.js ==="
curl -fsSL https://deb.nodesource.com/setup_"$NODE_LTS".x | bash - || {
  echo "ERROR: Failed to setup NodeSource. Check network connection or NodeSource availability."
  exit 1
}
apt-get install -y nodejs
node --version && npm --version || echo "Warning: Node.js or npm installation might have failed."


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

echo "=== Initial setup complete ==="
echo "Please log out and log back in for all changes (like docker group) to take effect."
