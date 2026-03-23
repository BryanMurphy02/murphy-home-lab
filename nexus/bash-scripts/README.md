# Server Scripts

## Scripts Overview

| Script | Description | Schedule |
|--------|-------------|----------|
| `system-health-check.sh` | Prints a formatted system health report to the terminal | On demand |
| `system-health-log.sh` | Silently logs system health metrics to a log file | Every hour via cron |
| `backup.sh` | Backs up key directories, compresses, and rotates old backups | Daily at 3am via cron |

---

## system-health-check.sh

A terminal utility that prints a quick, color-coded snapshot of the system.

**Output includes:**
- Hostname, kernel release, bash version, and running user
- CPU usage, free storage, and free memory
- Active Docker containers (if Docker is running)
- Status of monitored services: `tailscaled.service`, `smbd.service`

**Example output:**
```
 Quick system report for: bryan-server
    Kernel Release: 6.1.0-21-amd64
    Bash Version:   5.2.15(1)-release
    Running as:     bryan
    CPU Usage:      4.2%
    Free Storage:   120G
    Free Memory:    6.2Gi

    Active Docker Containers:
        my-container

    Other Active Services:
        tailscaled.service
        smbd.service
```

---

## system-health-log.sh

Silently logs the same system metrics as `system-health-check.sh` to a persistent log file. Intended to be run on a schedule via cron.

**Log file location:**
```
/var/log/system-health-check/sys-health.log
```

**Logged metrics:**
- Hostname, kernel version, bash version
- CPU usage, free storage, free memory
- Active Docker containers (if Docker is running)
- Status of monitored services: `tailscaled.service`, `smbd.service`

**Example log entries:**
```
[2026-03-23 03:00:01] [INFO] hostname:bryan-server
[2026-03-23 03:00:01] [INFO] cpu:4.2
[2026-03-23 03:00:01] [INFO] free storage:120G
[2026-03-23 03:00:01] [INFO] active-container:my-container
[2026-03-23 03:00:01] [INFO] active-service:tailscaled.service
```

**Cron schedule (every hour):**
```
0 * * * * /path/to/system-health-log.sh >> /var/log/system-health-check/cron.log 2>&1
```

---

## backup.sh

Backs up key server directories using `rsync`, saves a list of installed packages, compresses the backup, and removes backups older than 14 days. Must be run as root or with `sudo` to preserve file permissions.

**Directories backed up:**
- `/home/bryan`
- `/opt/docker`
- `/etc`

**What it does step by step:**
1. Creates a timestamped backup directory at `/srv/backups/server-backups-YYYY-MM-DD/`
2. Rsyncs each directory with full permission preservation (`-aAX --relative`)
3. Saves a list of installed packages via `dpkg --get-selections`
4. Compresses the backup directory into a `.tar.gz` archive
5. Deletes the uncompressed directory
6. Removes any `.tar.gz` backups older than 14 days from `/srv/backups/`
7. Logs the final archive size and total elapsed time

**Backup location:**
```
/srv/backups/server-backups-YYYY-MM-DD.tar.gz
```

**Log file location:**
```
/var/log/backups/backup.log
```

**Example log output:**
```
[2026-03-23 03:00:00] [INFO] script began at 2026-03-23 03:00:00
[2026-03-23 03:00:01] [INFO] backing up /home/bryan
[2026-03-23 03:00:05] [INFO] /home/bryan exists and backed up
[2026-03-23 03:00:05] [INFO] backing up /opt/docker
[2026-03-23 03:00:08] [INFO] /opt/docker exists and backed up
[2026-03-23 03:00:08] [INFO] backing up /etc
[2026-03-23 03:00:10] [INFO] /etc exists and backed up
[2026-03-23 03:00:10] [INFO] packages list exists and backed up
[2026-03-23 03:00:12] [INFO] backup compress success
[2026-03-23 03:00:12] [INFO] uncompressed backup deleted
[2026-03-23 03:00:12] [INFO] old backups deleted successfully
[2026-03-23 03:00:12] [INFO] Backup size: 2.3G
[2026-03-23 03:00:12] [INFO] total time elapsed: 72 seconds
[2026-03-23 03:00:12] [INFO] script end
```

---

## Dependencies

- `rsync` — file copying and syncing
- `tar` — backup compression
- `dpkg` — installed package listing (Debian/Ubuntu)
- `docker` — optional, queried if the Docker service is active
- `systemctl` — service status checks
- `top`, `df`, `free` — system metrics
