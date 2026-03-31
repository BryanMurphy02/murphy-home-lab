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

### Minecraft Server
- **Status:** 🟢 Running
- **Host:** Docker container
- **Ports:** 25565:25565
- **Description:** Game server for Minecraft

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

*Last updated: 2026-03-31*