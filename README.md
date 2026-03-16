# murphy-home-lab

Personal home lab running self-hosted media and services via Docker, across two machines — a primary Ubuntu Server mini PC (`nexus`) and a legacy Windows 11 desktop (`MurphyServer`).

---

## Hardware

### nexus — Primary Server (MINISFORUM UM760 Slim)

| Component | Details |
|-----------|---------|
| **Hostname** | nexus |
| **CPU** | AMD Ryzen 5 7640HS @ up to 5.0GHz (6C/12T) |
| **RAM** | 32GB DDR5 4800MHz |
| **OS** | Ubuntu Server (headless) |
| **Storage** | 1TB M.2 PCIe 4.0 NVMe SSD |
| **Network** | 2.5GbE + Wi-Fi 6E |

### MurphyServer — Legacy Desktop (Intel i7-6700)

| Component | Details |
|-----------|---------|
| **Hostname** | MurphyServer |
| **CPU** | Intel Core i7-6700 @ 3.40GHz (4C/8T) |
| **RAM** | 8GB DDR4 2133MHz (upgrade to 32GB planned) |
| **OS** | Windows 11 64-bit |
| **Storage** | 150GB SSD (OS) + Internal HDD (media at `D:\Plex`) |
| **Network** | Ethernet |

> Full hardware specs: [nexus](docs/hardware-nexus.md) · [MurphyServer](docs/hardware-murphyserver.md)

---

## Services

| Service | Host | Description | Status |
|---------|------|-------------|--------|
| [Plex Media Server](https://plex.tv) | MurphyServer | Media streaming server | ✅ Running |

---

## Infrastructure

- **Primary server:** `nexus` — MINISFORUM UM760 Slim running Ubuntu Server (headless)
- **Legacy server:** `MurphyServer` — Windows 11 desktop, currently hosting Plex
- **Containerization:** Docker Desktop on MurphyServer (Windows); Docker on nexus (Ubuntu)
- **Restart policy:** `unless-stopped` on all containers (auto-starts on reboot)
- **Remote access:** SSH for nexus management; RDP for MurphyServer management
- **Port forwarding:** Port `32400` forwarded to MurphyServer for Plex remote access

---

## Network

| Service | Host | Internal Port | External Port |
|---------|------|--------------|---------------|
| Plex | MurphyServer | 32400 | 32400 |

---

## Directory Structure

### nexus (Ubuntu Server)
```
~/docker/
└── (services to be migrated here)
```

### MurphyServer (Windows 11)
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

---

## Docs

- [nexus Hardware](docs/hardware-nexus.md) — MINISFORUM UM760 Slim full specs
- [MurphyServer Hardware](docs/hardware-murphyserver.md) — Intel i7-6700 desktop full specs
- [Plex Migration Guide](docs/plex-migration.md) — Steps for moving Plex to a new machine