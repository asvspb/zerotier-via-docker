#!/bin/bash
set -e

# Запуск демона ZeroTier
service zerotier-one start

# Ожидание запуска демона
sleep 3

# Присоединение к сети
if [ -n "$ZT_NETWORK_ID" ]; then
    zerotier-cli join "$ZT_NETWORK_ID"
fi

# Ожидание авторизации (можно доработать ожидание статуса)
sleep 10

# Включение IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Настройка NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Ожидание (чтобы контейнер не завершался)
tail -f /dev/null
