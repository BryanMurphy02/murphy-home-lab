# Nexus Server — Services

A living document of what's installed and running on this server.

---

## Installed Software

### Docker
- **Status:** ✅ Installed & Running
- **Purpose:** Container runtime for managing services

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

### Portainer
- **Status:** 🟢 Running
- **Host:** Docker container
- **Ports:** 9443, 8000
- **Description:** Docker management GUI

### Minecraft Server
- **Status:** 🟢 Running
- **Host:** Docker container
- **Ports:** 25565:25565
- **Description:** Game server for Minecraft

### Samba
- **Status:** 🟢 Running
- **Host:** Native (systemd)
- **Ports:** 445, 139
- **Share:** `\\10.0.0.99\dropzone` → `/home/bryan/dropzone`
- **Description:** Network drive for file transfers from Windows to Nexus

### Tailscale
- **Status:** 🟢 Running
- **Host:** Native (systemd)
- **Tailscale IP:** `100.x.x.x` (see `tailscale ip` for current address)
- **Description:** Allows SSH and remote access to Nexus from outside the local network

---

*Last updated: 2026-03-16*