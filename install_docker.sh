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

echo "Готово!"
