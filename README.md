# murphy-home-lab

Personal home lab server running self-hosted media and services via Docker on Windows 11.

---

## Hardware

| Component | Details |
|-----------|---------|
| **Device** | MurphyServer |
| **CPU** | Intel Core i7-6700 @ 3.40GHz |
| **RAM** | 8GB DDR4 2133MHz (upgrade to 32GB planned) |
| **OS** | Windows 11 |
| **Storage** | Internal HDD for media (`D:\Plex`) |

---

## Services

| Service | Description | Status |
|---------|-------------|--------|
| [Plex Media Server](https://plex.tv) | Media streaming server | ✅ Running |

---

## Infrastructure

- **Containerization:** Docker Desktop on Windows 11
- **Restart policy:** `unless-stopped` on all containers (auto-starts on reboot)
- **Remote access:** RDP for server management, Plex remote access via port forwarding
- **Port forwarding:** Port `32400` forwarded to host machine for Plex remote access

---

## Network

| Service | Internal Port | External Port |
|---------|--------------|---------------|
| Plex | 32400 | 32400 |

---

## Directory Structure

```
C:\Docker\
└── Plex\
    ├── docker-compose.yml
    ├── config\        — Plex metadata and databases
    └── transcode\     — Temporary transcode scratch space

D:\Plex\               — Media library
```

---

## Secrets & Environment Variables

Sensitive values (API keys, tokens, passwords) are stored in a local `.env` file and are never committed to this repo. A `.env.example` file documents the required variables without values.

---

## Planned Upgrades

- [ ] RAM upgrade to 32GB DDR4 2133MHz
- [ ] Arr stack (Sonarr, Radarr, Prowlarr, qBittorrent, Overseerr)
- [ ] Game server
- [ ] Self-hosted website
- [ ] Migrate from Windows 11 to Ubuntu Desktop

---

## Docs

- [Plex Migration Guide](docs/plex-migration.md) — Steps for moving Plex to a new machine