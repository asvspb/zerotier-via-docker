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

sleep 10

# Включение IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Настройка NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Ожидание (чтобы контейнер не завершался)
tail -f /dev/null

# Проверка статуса подключения к сети
if [ -n "$ZT_NETWORK_ID" ]; then
    STATUS="$(zerotier-cli listnetworks | grep "$ZT_NETWORK_ID" | awk '{print $5}')"
    if [ "$STATUS" = "OK" ]; then
        echo "[INFO] Успешно подключено к ZeroTier сети $ZT_NETWORK_ID (статус: $STATUS)"
    else
        echo "[WARN] Не удалось подтвердить успешное подключение к сети $ZT_NETWORK_ID (статус: $STATUS)"
    fi
fi
