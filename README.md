# ZeroTier via Docker – **multi-stack repository**

This repository aggregates **three independent Docker stacks** for different ZeroTier use-cases:

| Stack | Purpose | Containers | Default Ports |
|-------|---------|------------|---------------|
| **ztnexitnode/** | Lightweight exit-node (NAT gateway) for an *existing* ZeroTier network | 1 (ZeroTier One + NAT) | host network (9993/udp) |
| **ztnet/** | Full self-hosted controller [**ZTNET**](https://github.com/sinamics/ztnet)  (Next.js UI + Postgres + ZeroTier) | 3 (`postgres`, `zerotier`, `ztnet`) | 9993/udp, 3000/tcp |
| **ztncui/** | All-in-one image [keynetworks/ztncui](https://github.com/key-networks/ztncui) (ZeroTier One + ztncui UI) | 1 | 9993/udp, 3443/tcp (HTTPS), 3180/tcp (HTTP FS) |

---
**Fresh server?** Run `initial-server-setup.sh` once on a pristine Ubuntu 22.04 host. It installs Docker + Compose v2, Node LTS, Python-Poetry, PostgreSQL, UFW/Fail2ban, Zsh/tmux and other essentials.

## Requirements
* Linux x86-64, ≥1 CPU, ≥1 GiB RAM  
* Ubuntu 22.04 server (other Debian/Ubuntu releases also work with minor tweaks)  
* **Docker 23+** and **Docker Compose v2** – both are installed automatically by `initial-server-setup.sh`

Each sub-directory provides a ready-to-run `docker-compose.yml`, an `.env.example` file and a convenience installer `install_*.sh`.

> No need to work as **root**. After Docker installation the script adds your current user to the `docker` group.

---
## 1 – ztnexitnode/  (simple ZeroTier exit-node)
### Features
* Runs `zerotier-one` inside the container.
* Automatically joins the network specified by `ZT_NETWORK_ID`.
* Enables IP forwarding and NAT (MASQUERADE) – the server becomes an internet gateway for all ZeroTier peers.

### Quick start
```bash
# install docker if required and copy env template
./install_exitnode.sh

# edit ztnexitnode/.env and set ZT_NETWORK_ID (+ optional ZT_TOKEN)

cd ztnexitnode
# build & start
docker compose up -d --build
```

### Logs & diagnostics
```bash
docker compose logs -f zerotier          # tail container output
docker exec -it zerotier-exitnode zerotier-cli listnetworks
```
Once another client joins the same network, check its external IP (`curl ifconfig.me`). It should match the server’s public address.

### Common issues
| Symptom | Fix |
|---------|-----|
| `NOT_AUTHORIZED` in logs | Open ZeroTier Central and **Authorize** the new node. |
| No internet through gateway | Enable *Allow Global* for the node **and** *Allow default route* on the client. |
| `iptables: Permission denied` | Container must run with `cap_add: NET_ADMIN` (already present). |

---
## 2 – ztnet/  (ZTNET controller)
**ZTNET** is a self-hosted replacement for my.zerotier.com featuring a modern Next.js UI and NextAuth authentication.

### Setup
```bash
./install_ztnet.sh            # installs docker & copies .env
# open ztnet/.env → change POSTGRES_PASSWORD, NEXTAUTH_URL, NEXTAUTH_SECRET

cd ztnet
docker compose up -d
```
The first registered user automatically receives admin privileges.

### Useful commands
```bash
docker compose logs -f ztnet        # web app
docker compose logs -f postgres     # database
```

### Update
```bash
cd ztnet
docker compose pull
docker compose up -d
```

---
## 3 – ztncui/  (all-in-one keynetworks/ztncui)
`ztncui` is a compact Node.js UI for the built-in ZeroTier controller.

### Deployment
```bash
./install_ztncui.sh          # copies .env and offers to insert public IP into MYADDR

cd ztncui
docker compose up -d
```
UI will be available at `https://<MYADDR>:3443` (self-signed TLS). Default admin credentials: `admin / password` unless `ZTNCUI_PASSWD` is set.

### Logs
```bash
docker compose logs -f ztncui
```

---
## Updating / Removing
```bash
# update images
cd <stack>
docker compose pull
# restart with new versions
docker compose up -d
# stop and remove containers & network
docker compose down
# remove volumes if no longer needed
docker volume rm <volume_name>
```

---
## Troubleshooting checklist
1. **Container exits immediately** – inspect with `docker compose logs <service>`. Most often caused by wrong `ZT_TOKEN` / `ZT_NETWORK_ID`.
2. **Port already in use** – adjust port mapping in `docker-compose.yml` or override via env.
3. **net.ipv4.ip_forward = 0** inside exitnode – ensure no conflicting `sysctl.d` rule on host; worst case: `sudo sysctl -w net.ipv4.ip_forward=1` on the host.
4. **Browser TLS warning** in ztncui – replace the self-signed certificate or put Caddy/Nginx in front.

---
## Licenses
* Repository code – MIT license.  
* External images follow their own licenses: **ZTNET** – MIT, **ztncui** – GPLv3, **ZeroTier One** – BSL.

---

