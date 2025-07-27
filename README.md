# ZeroTier Exit Node via Docker

Этот проект позволяет быстро развернуть ZeroTier в режиме exit node на сервере Ubuntu с помощью Docker. Все сетевые настройки и автоматизация перенесены из скрипта [zt_exitnode.sh](https://github.com/anten-ka/zt_exitnode/blob/main/zt_exitnode.sh) в контейнерную среду.

## Возможности
- Установка и запуск ZeroTier в Docker-контейнере
- Автоматическое подключение к вашей ZeroTier-сети
- Настройка сервера как exit node (маршрутизация и NAT)
- Гибкая конфигурация через переменные окружения


## Подробная инструкция по запуску на сервере Ubuntu

### 1. Подготовка сервера

- Убедитесь, что на сервере установлен Docker и docker-compose:
  ```bash
  sudo apt update
  sudo apt install -y docker.io docker-compose
  sudo systemctl enable --now docker
  ```

- (Рекомендуется) Добавьте своего пользователя в группу docker:
  ```bash
  sudo usermod -aG docker $USER
  # Перезайдите в сессию или выполните: newgrp docker
  ```

### 2. Клонирование репозитория

```bash
git clone https://github.com/asvspb/zerotier-via-docker.git
cd zerotier-via-docker
```

### 3. Настройка переменных окружения

- Скопируйте пример файла и отредактируйте:
  ```bash
  cp .env.example .env
  nano .env
  # Укажите ваш ZT_NETWORK_ID и другие параметры
  ```

### 4. Сборка и запуск контейнера

```bash
docker-compose up -d --build
```

### 5. Авторизация узла в ZeroTier Central

- Перейдите в https://my.zerotier.com/network/<ваш_network_id>
- Найдите новый узел (Node ID) и авторизуйте его (Allow).

### 6. Проверка работы exit node

- Подключитесь к этой же ZeroTier-сети с другого устройства.
- Проверьте, что через сервер проходит интернет-трафик (например, сравните IP через https://ifconfig.me).
- Для диагностики используйте:
  ```bash
  docker logs zerotier-exitnode
  docker exec -it zerotier-exitnode bash
  zerotier-cli info
  zerotier-cli listnetworks
  ```

### 7. Остановка и удаление

```bash
docker-compose down
```

---

## Быстрый старт

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/asvspb/zerotier-via-docker.git
   cd zerotier-via-docker
   ```

2. **Настройте переменные окружения:**
   - Создайте файл `.env` или укажите переменные в `docker-compose.yml`:
     - `ZT_NETWORK_ID` — ID вашей ZeroTier-сети
     - `ZT_TOKEN` (опционально) — токен авторизации

3. **Запустите контейнер:**
   ```bash
   docker-compose up -d
   ```

4. **Авторизуйте устройство в ZeroTier Central (если требуется).**

5. **Проверьте работу exit node:**
   - Подключитесь к сети ZeroTier с другого устройства и проверьте маршрутизацию через сервер.

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
