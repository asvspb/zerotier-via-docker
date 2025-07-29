#!/bin/bash

set -e

# Verify that required environment file is mounted
if [ ! -f /entrypoint.env ]; then
    echo "[FATAL] /entrypoint.env not found. Provide environment variables as a file or via docker-compose 'env_file'."
    exit 1
fi
source /entrypoint.env

# Check Docker availability inside the container (optional sanity check)
if ! command -v docker &> /dev/null; then
    echo "[FATAL] Docker binary not found inside container. Please rebuild using the updated exitnode stack."
    exit 1
fi

# Start ZeroTier daemon
service zerotier-one start
sleep 3

# Join the specified network
if [ -n "$ZT_NETWORK_ID" ]; then
    zerotier-cli join "$ZT_NETWORK_ID"
else
    echo "[FATAL] ZT_NETWORK_ID not provided. Edit .env and rebuild the container."
    exit 1
fi

# Wait for successful connection (max 60 s)
echo "Waiting for ZeroTier network $ZT_NETWORK_ID connection …"
for i in {1..30}; do
    STATUS="$(zerotier-cli listnetworks | grep "$ZT_NETWORK_ID" | awk '{print $5}')"
    if [ "$STATUS" = "OK" ]; then
        echo "[INFO] Joined ZeroTier network $ZT_NETWORK_ID (status: $STATUS)"
        break
    else
        echo "[WAIT] Status: $STATUS … ($i/30)"
        sleep 2
    fi
done

# Enable IPv4 forwarding & set up NAT
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Keep container running
exec tail -f /dev/null
