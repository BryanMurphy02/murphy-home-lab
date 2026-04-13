# Nexus Server — Services

A living document of what's installed and running on this server.

---

## Installed Software

### Docker
- **Status:** ✅ Installed & Running
- **Purpose:** Container runtime for managing services

### Nginx
- **Status:** ✅ Installed & Running
- **Purpose:** Web server and reverse proxy for routing traffic to hosted services

### Immich
- **Status:** ✅ Installed & Running
- **Purpose:** Self-hosted photo and video backup and management

### Calibre-Web Automated
- **Status:** ✅ Installed & Running
- **Purpose:** Self-hosted e-book library manager with automatic book ingestion

### Git
- **Status:** ✅ Installed
- **Purpose:** Version control

### Samba
- **Status:** ✅ Installed & Running
- **Purpose:** Network file sharing between Nexus and Windows machines

### Tailscale
- **Status:** ✅ Installed & Running
- **Purpose:** Secure remote access via private mesh VPN (WireGuard-based)
---

## Running Services

### Nginx
- **Status:** 🟢 Running
- **Host:** Docker container
- **Ports:** 80
- **Network:** `nexus-network`
- **Description:** Reverse proxy that handles incoming web traffic and routes it to the appropriate service. Currently proxies to the Digital Library app.

### Digital Library
- **Status:** 🟢 Running
- **Host:** Docker container (separate docker-compose)
- **Network:** `nexus-network`
- **Stack:** Python Flask (web framework) + PostgreSQL (database, bundled in same container)
- **Repo:** [BryanMurphy02/digital-library](https://github.com/BryanMurphy02/digital-library)
- **Description:** Personal web app served via Nginx. A self-hosted digital library accessible through the browser on port 80.

### Allergy Safe Recipes
- **Status:** 🟢 Running
- **Host:** Docker container (multi-container stack)
- **Network:** `nexus-network` (frontend only), `frontend` (frontend ↔ api), `backend` (api, scraper ↔ database)
- **Stack:** PostgreSQL (database), scraper (recipe ingestion), FastAPI (api), React/Nginx (frontend)
- **Repo:** [BryanMurphy02/allergy-safe-recipes](https://github.com/BryanMurphy02/allergy-safe-recipes)
- **Description:** Containerised recipe discovery app served via Nginx on port 9001. Scrapes recipes from BBC Good Food and Budget Bytes, detects allergens and dietary tags

### Immich
- **Status:** 🟢 Running
- **Host:** Docker container (multi-container stack)
- **Network:** `nexus-network` (immich-server only), `default` (internal stack communication)
- **Stack:** immich-server, immich-machine-learning, Valkey/Redis, PostgreSQL (with vector extensions)
- **Library:** `/home/bryan/immich/library`
- **Database:** `/home/bryan/immich/postgres`
- **Description:** Self-hosted photo and video management platform, served via Nginx on port 2283

### Minecraft Server
- **Status:** 🟢 Running
- **Host:** Docker container
- **Ports:** 25565:25565
- **Description:** Game server for Minecraft

### Calibre-Web Automated
- **Status:** 🟢 Running
- **Host:** Docker container
- **Network:** `nexus-network`
- **Image:** `crocodilestick/calibre-web-automated:latest`
- **Config/Data:** `/opt/docker/cwa/`
- **Description:** Self-hosted e-book library and reader interface, served via Nginx on port 8083. Uses the Calibre-Web Automated image which adds automatic book ingestion — books dropped into the ingest folder are automatically processed and added to the library.

### Tailscale
- **Status:** 🟢 Running
- **Host:** Native (systemd)
- **Tailscale IP:** `100.x.x.x` (see `tailscale ip` for current address)
- **Description:** Allows SSH and remote access to Nexus from outside the local network

### Portainer
- **Status:** 🟢 Running
- **Host:** Docker container
- **Ports:** 9443, 8000
- **Description:** Docker management GUI

### Samba
- **Status:** 🟢 Running
- **Host:** Native (systemd)
- **Ports:** 445, 139
- **Share:** `\\10.0.0.99\dropzone` → `/home/bryan/dropzone`
- **Description:** Network drive for file transfers from Windows to Nexus

---
 
## Docker Networks
 
### nexus-network
- **Type:** User-defined bridge network
- **Purpose:** Allows Nginx and Digital Library containers to communicate internally without exposing inter-service traffic to the host network
 
---

*Last updated: 2026-04-13*