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

---

*Last updated: 2026-03-16*