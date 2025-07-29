#!/bin/bash
set -e

if [ ! -f /entrypoint.env ]; then
  echo "[FATAL] /entrypoint.env not found; ensure env vars are passed as file or docker-compose env."; exit 1;
fi
source /entrypoint.env

service zerotier-one start
sleep 3

if [ -n "$ZT_NETWORK_ID" ]; then
  zerotier-cli join "$ZT_NETWORK_ID"
fi

for i in {1..30}; do
  STATUS=$(zerotier-cli listnetworks | grep "$ZT_NETWORK_ID" | awk '{print $5}')
  [[ "$STATUS" == "OK" ]] && break
  sleep 2
done

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

tail -f /dev/null
