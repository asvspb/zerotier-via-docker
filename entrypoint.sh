
#!/bin/bash
set -e

# Проверка наличия .env и docker
if [ ! -f /entrypoint.env ]; then
    echo "[FATAL] Не найден файл .env. Пожалуйста, сначала выполните install_docker.sh для настройки окружения и регистрации ZT_NETWORK_ID."
    exit 1
fi
source /entrypoint.env
if ! command -v docker &> /dev/null; then
    echo "[FATAL] Docker не установлен. Пожалуйста, выполните install_docker.sh."
    exit 1
fi

# Запуск демона ZeroTier
service zerotier-one start

# Ожидание запуска демона
sleep 3

# Присоединение к сети
if [ -n "$ZT_NETWORK_ID" ]; then
    zerotier-cli join "$ZT_NETWORK_ID"
else
    echo "[FATAL] ZT_NETWORK_ID не задан. Пожалуйста, выполните install_docker.sh и настройте .env."
    exit 1
fi

# Ожидание успешного подключения к сети
if [ -n "$ZT_NETWORK_ID" ]; then
    echo "Ожидание подключения к ZeroTier сети $ZT_NETWORK_ID..."
    for i in {1..30}; do
        STATUS="$(zerotier-cli listnetworks | grep "$ZT_NETWORK_ID" | awk '{print $5}')"
        if [ "$STATUS" = "OK" ]; then
            echo "[INFO] Успешно подключено к ZeroTier сети $ZT_NETWORK_ID (статус: $STATUS)"
            break
        else
            echo "[WAIT] Статус: $STATUS. Ожидание... ($i/30)"
            sleep 2
        fi
    done
    if [ "$STATUS" != "OK" ]; then
        echo "[WARN] Не удалось подтвердить успешное подключение к сети $ZT_NETWORK_ID (статус: $STATUS)"
    fi
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
