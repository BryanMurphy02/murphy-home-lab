# Plex Media Server — Migration Guide
Moving to a New Machine

---

## Overview

This guide covers everything needed to move your Plex Media Server Docker setup from one machine to another. The process involves copying your Docker config, copying your Plex metadata, and pointing the new server at your media files.

**Estimated time:** 15–30 minutes depending on metadata size.

---

## Prerequisites

- Docker Desktop installed on the new machine
- Access to both machines simultaneously (or a USB/network share)
- Your media files accessible on the new machine
- Port 32400 available on the new machine

---

## Step 1 — Copy Your Docker Compose File

Copy your entire Plex project folder to the new machine. This folder contains:

- `docker-compose.yml`
- `config\` — all Plex metadata and databases
- `transcode\` — can be left empty or skipped

**Default location on Windows:** `C:\Docker\Plex\`

---

## Step 2 — Stop the Old Server

On the old machine, stop the Plex container so no new metadata is written:

```bash
docker compose down
```

> **Important:** Do not skip this step. If Plex is still running and writing to the database while you copy it, the copied database may be corrupted.

---

## Step 3 — Copy Metadata to the New Machine

Copy the entire `config\` folder from the old machine to the new machine. The two most critical subfolders are:

**`config\Library\Application Support\Plex Media Server\Databases\`**
Contains watch history, ratings, playlists, collections, and metadata.

**`config\Library\Application Support\Plex Media Server\Metadata\`**
Contains posters, artwork, thumbnails, and cached media info.

---

## Step 4 — Update the Compose File for the New Machine

Open `docker-compose.yml` on the new machine and update the media path:

```yaml
volumes:
  - ./config:/config
  - ./transcode:/transcode
  - /NEW/PATH/TO/MEDIA:/data    # update this line
```

> **Windows note:** Drive letters use forward slashes. For example `D:\Plex` becomes `/d/Plex` in the compose file.

---

## Step 5 — Start the New Server

Navigate to your Plex folder and start the container:

```bash
docker compose up -d
```

Verify it is running:

```bash
docker compose ps
```

Then open `http://localhost:32400/web` in your browser. You should see your existing libraries and metadata — no setup wizard should appear.

---

## Step 6 — Update Port Forwarding on Your Router

Update your router's port forward rule to point to the new machine's local IP:

1. Find the new machine's local IP: run `ipconfig` and look for the IPv4 address
2. Log into your router admin panel (usually `http://192.168.1.1`)
3. Find the existing port `32400` forward rule
4. Update the destination IP to the new machine's IP
5. Save the rule

> **Tip:** Set a static IP or DHCP reservation for the new machine so this never needs updating again.

---

## Step 7 — Verify Remote Access in Plex

Inside Plex on the new server:

1. Go to **Settings → Remote Access**
2. Check **"Manually specify public port"** and enter `32400`
3. Click Save and confirm the green checkmark appears

---

## What Your Users Will Experience

As long as the server name matches and you are signed into the same Plex account, your users should notice nothing. Their apps will automatically find the server. Watch history, pinned libraries, and continue watching will all be preserved from the migrated metadata.

> **Note:** It may take a few minutes for remote users' apps to discover the new server. If anyone has trouble, ask them to close and reopen their Plex app.

---

## Troubleshooting

**Port 32400 already in use**
The old Plex app or another service is using the port. Run `netstat -ano | findstr :32400` to find the process and stop it before starting the container.

**"Not Authorised" in browser**
The server is running but not claimed. Check that `config\` copied correctly and that `Preferences.xml` exists inside `config\Library\Application Support\Plex Media Server\`.

**Libraries are empty or media not found**
The media path in `docker-compose.yml` is incorrect. Verify the volume mount points to the right folder and libraries are set to scan `/data`.

**Streaming says "limited" after move**
Your router's port forward rule still points to the old machine. Update it to the new machine's IP as described in Step 6.

---

*Keep this file with your `docker-compose.yml` for future reference.*