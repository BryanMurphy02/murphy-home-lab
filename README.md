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
- **Containerization:** Docker on nexus (Ubuntu); Docker Desktop on MurphyServer (Windows)
- **Remote access:** SSH for nexus management; RDP for MurphyServer management

---

## Directory Structure

### nexus (Ubuntu Server)
```
/opt/
├── docker/
│   ├── digital-library/
│   │   └── docker-compose.yml
│   ├── minecraft/
│   │   └── docker-compose.yml
│   └── nginx/
│       └── docker-compose.yml
└── my-scripts/
    └── (cron automated bash and python scripts)
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

## Docs

- [nexus Hardware](docs/hardware-nexus.md) — MINISFORUM UM760 Slim full specs
- [MurphyServer Hardware](docs/hardware-murphyserver.md) — Intel i7-6700 desktop full specs
- [Plex Migration Guide](docs/plex-migration.md) — Steps for moving Plex to a new machine