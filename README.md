# ZeroTier via Docker - Monorepo

Это мультипроект для различных сценариев работы с ZeroTier в Docker.

Каталоги:

1. exitnode/  – лёгкий контейнер для поднятия сервера-выхода (NAT) в вашей существующей сети ZeroTier.
2. ztnet/     – полноценный self-host контроллер ZTNET (Postgres + UI + встроенный zerotier).
3. ztncui/    – all-in-one образ keynetworks/ztncui (ZeroTier One + ztncui UI) без внешней БД.

Скрипты установки
-----------------
• install_exitnode.sh – проверяет/ставит Docker, копирует env, напоминает запустить `docker compose up -d` в exitnode.
• install_ztnet.sh    – аналогично для каталога ztnet.
• install_ztncui.sh   – аналогично для каталога ztncui.

Выбери��е нужный вариант и следуйте README внутри соответствующей папки.
