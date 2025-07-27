#!/bin/bash
# Скрипт для проверки и установки Docker и docker-compose на Ubuntu
set -e

# Проверка наличия docker
if ! command -v docker &> /dev/null; then
    echo "Docker не найден. Устанавливаю..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable --now docker
else
    echo "Docker уже установлен."
fi

# Проверка наличия docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose не найден. Устанавливаю..."
    sudo apt install -y docker-compose
else
    echo "docker-compose уже установлен."
fi

# (Опционально) Добавить пользователя в группу docker
if ! groups $USER | grep -q docker; then
    echo "Добавляю пользователя $USER в группу docker..."
    sudo usermod -aG docker $USER
    echo "Перезайдите в сессию или выполните: newgrp docker"
fi


# --- Интерактивная настройка ZT_NETWORK_ID и создание .env ---
cd "$(dirname "$0")"
if [ ! -f .env ]; then
    echo
    read -rp "Введите ваш ZT_NETWORK_ID (ID вашей ZeroTier-сети): " ZT_NETWORK_ID
    echo "ZT_NETWORK_ID=$ZT_NETWORK_ID" > .env
    echo "ZT_TOKEN=" >> .env
    echo "ZT_NODE_NAME=" >> .env
    echo ".env создан."
else
    echo ".env уже существует, пропускаю создание."
fi

echo "Готово!"
echo
echo "--- Лог подключения к сети ---"
if [ -n "$ZT_NETWORK_ID" ]; then
    echo "Для подключения к сети используйте:"
    echo "  docker-compose up -d --build"
    echo "Затем проверьте логи контейнера командой:"
    echo "  docker logs zerotier-exitnode"
    echo "или внутри контейнера:"
    echo "  docker exec -it zerotier-exitnode zerotier-cli listnetworks"
fi
