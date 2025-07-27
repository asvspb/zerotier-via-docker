# ZeroTier Exit Node via Docker

This project allows you to quickly deploy ZeroTier as an exit node on an Ubuntu server using Docker. All network configuration and automation are containerized, based on the [zt_exitnode.sh](https://github.com/anten-ka/zt_exitnode/blob/main/zt_exitnode.sh) script.

## Features
- Install and run ZeroTier in a Docker container
- Automatic connection to your ZeroTier network
- Configure the server as an exit node (routing and NAT)
- Flexible configuration via environment variables

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/asvspb/zerotier-via-docker.git
   cd zerotier-via-docker
   ```

2. **Run the installation and setup script:**
   ```bash
   bash install_docker.sh
   ```
   The script will:
   - Check and install Docker and docker-compose
   - Add your user to the docker group (if needed)
   - Ask for your ZT_NETWORK_ID and create .env

3. **Build and start the container:**
   ```bash
   docker-compose up -d --build
   ```

4. **Authorize the node in ZeroTier Central:**
   - Go to https://my.zerotier.com/network/<your_network_id>
   - Find the new node (Node ID) and authorize it (Allow).

5. **Check exit node operation:**
   - Connect to the same ZeroTier network from another device.
   - Check that internet traffic goes through the server (for example, compare IP via https://ifconfig.me).
   - For diagnostics, use:
     ```bash
     docker logs zerotier-exitnode
     docker exec -it zerotier-exitnode bash
     zerotier-cli info
     zerotier-cli listnetworks
     ```

6. **Stop and remove:**
   ```bash
   docker-compose down
   ```

---

## Project structure

- `Dockerfile` — builds the image with ZeroTier and required tools
- `docker-compose.yml` — launches the container with the necessary privileges and variables
- `entrypoint.sh` — automates startup, network join, and NAT setup
- `README.md` — documentation
- `.env.example` — example environment file

## Environment variables
- `ZT_NETWORK_ID` — your ZeroTier network ID (required)
- `ZT_TOKEN` — authorization token (optional)
- `ZT_NODE_NAME` — node name (optional)

## Requirements
- Docker and docker-compose
- Ubuntu server (or other Linux)

## Security
- The container requires `NET_ADMIN` privileges to set up network rules.
- Recommended to run only on trusted servers.

## License
MIT or similar open license.

---

# ZeroTier Exit Node via Docker (на русском)

Этот проект позволяет быстро развернуть ZeroTier в режиме exit node на сервере Ubuntu с помощью Docker. Все сетевые настройки и автоматизация перенесены из скрипта [zt_exitnode.sh](https://github.com/anten-ka/zt_exitnode/blob/main/zt_exitnode.sh) в контейнерную среду.

## Возможности
- Установка и запуск ZeroTier в Docker-контейнере
- Автоматическое подключение к вашей ZeroTier-сети
- Настройка сервера как exit node (маршрутизация и NAT)
- Гибкая конфигурация через переменные окружения

## Быстрый старт

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/asvspb/zerotier-via-docker.git
   cd zerotier-via-docker
   ```

2. **Запустите скрипт установки и настройки:**
   ```bash
   bash install_docker.sh
   ```
   Скрипт:
   - Проверит и установит Docker и docker-compose
   - Добавит пользователя в группу docker (если нужно)
   - Запросит у вас ZT_NETWORK_ID и создаст .env

3. **Соберите и запустите контейнер:**
   ```bash
   docker-compose up -d --build
   ```

4. **Авторизуйте узел в ZeroTier Central:**
   - Перейдите в https://my.zerotier.com/network/<ваш_network_id>
   - Найдите новый узел (Node ID) и авторизуйте его (Allow).

5. **Проверьте работу exit node:**
   - Подключитесь к этой же ZeroTier-сети с другого устройства.
   - Проверьте, что через сервер проходит интернет-трафик (например, сравните IP через https://ifconfig.me).
   - Для диагностики используйте:
     ```bash
     docker logs zerotier-exitnode
     docker exec -it zerotier-exitnode bash
     zerotier-cli info
     zerotier-cli listnetworks
     ```

6. **Остановка и удаление:**
   ```bash
   docker-compose down
   ```

---

## Структура проекта

- `Dockerfile` — сборка образа с ZeroTier и необходимыми утилитами
- `docker-compose.yml` — запуск контейнера с нужными правами и переменными
- `entrypoint.sh` — автоматизация запуска, подключения к сети и настройки NAT
- `README.md` — документация
- `.env.example` — пример файла переменных окружения

## Переменные окружения
- `ZT_NETWORK_ID` — ID вашей ZeroTier-сети (обязательно)
- `ZT_TOKEN` — токен авторизации (опционально)
- `ZT_NODE_NAME` — имя узла (опционально)

## Требования
- Docker и docker-compose
- Сервер Ubuntu (или другой Linux)

## Безопасность
- Контейнер требует привилегий `NET_ADMIN` для настройки сетевых правил.
- Рекомендуется запускать только на доверенных серверах.

## Лицензия
MIT или аналогичная свободная лицензия.
