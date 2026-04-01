# Nexus Server — Scripts

Documentation for the automated scripts located in `/opt/my-scripts/` on nexus. All scripts are scheduled via cron and write logs to `/var/log/my-scripts/`.

---

## backup.sh

- **Language:** Bash
- **Schedule:** Daily
- **Log:** `/var/log/my-scripts/backups/backup.log`

### What it does
Creates a dated backup of critical server directories using `rsync`, generates a list of all installed packages, compresses the result into a `.tar.gz` archive, and cleans up backups older than 14 days.

### Backup targets
- `/home/bryan` — user home directory
- `/opt` — Docker compose projects and scripts
- `/etc` — system configuration files
- Installed packages list via `dpkg --get-selections`

### Process
1. Creates `/srv/backups/server-backups-<date>/` as the staging directory
2. Rsyncs each target into the staging directory
3. Saves installed package list to `<backup-dir>/packages/installed-packages.txt`
4. Compresses the staging directory to `<backup-dir>.tar.gz`
5. Deletes the uncompressed staging directory
6. Purges any `.tar.gz` backups in `/srv/backups/` older than 14 days

### Logging
Each step is logged with a timestamp and severity level (`INFO` / `ERR`). The log records script start/end times and total elapsed time.

---

## process-monitor.py

- **Language:** Python
- **Schedule:** Hourly
- **Log:** `/var/log/my-scripts/process-monitor/process-monitor.log`
- **Dependencies:** `psutil` (`pip3 install psutil`)

### What it does
Checks the health of system resources, Docker containers, and key services. Logs a status for each with severity levels based on defined thresholds.

### Checks performed

#### System Info
Logs hostname, kernel version, and uptime on every run.

#### CPU Usage
| Threshold | Level |
|-----------|-------|
| < 70% | INFO |
| ≥ 70% | WARNING |
| ≥ 90% | ERROR |

#### Memory Usage
| Threshold | Level |
|-----------|-------|
| < 75% | INFO |
| ≥ 75% | WARNING |
| ≥ 90% | ERROR |

#### Disk Usage
| Threshold | Level |
|-----------|-------|
| < 70% | INFO |
| ≥ 70% | WARNING |
| ≥ 90% | ERROR |

#### Docker Containers
| Check | Level if down |
|-------|--------------|
| Docker service | ERROR |
| Minecraft (`hopefully-this-world-lasts`) | WARNING |
| Portainer | WARNING |

All running container names are logged at INFO level.

#### Services
| Service | Level if down |
|---------|--------------|
| Tailscale (`tailscaled.service`) | ERROR |
| Samba (`smbd.service`) | WARNING |

---

## log-analyzer.py

- **Language:** Python
- **Schedule:** Daily
- **Log:** `/var/log/my-scripts/report.log`

### What it does
Scans all `.log` files under `/var/log/my-scripts/` (excluding `report.log` itself), isolates the most recent run of each script, parses each line using regex, and writes a structured summary report.

### Process
1. **Discovery** — Recursively finds all `*.log` files under `/var/log/my-scripts/`
2. **Parsing** — For each log file, scans backwards to find the most recent `script began` line and slices from there to end of file. Each line is parsed into `timestamp`, `level`, and `message` using the pattern `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`
3. **Analysis** — Determines overall run status, collects all errors and warnings, and calculates run duration from start/end timestamps
4. **Reporting** — Writes a formatted report to `report.log`

### Run statuses
| Status | Meaning |
|--------|---------|
| `SUCCESS` | No errors or warnings |
| `WARNING` | One or more warnings, no errors |
| `ERROR` | One or more errors |
| `INCOMPLETE` | No `script end` line found in the most recent run |

### Report format
```
========================================
LOG ANALYSIS REPORT — YYYY-MM-DD HH:MM
========================================

[ script-name ]
Status:    SUCCESS / WARNING / ERROR / INCOMPLETE
Started:   YYYY-MM-DD HH:MM:SS
Ended:     YYYY-MM-DD HH:MM:SS
Duration:  HH:MM:SS
Errors:    0
Warnings:  0
========================================
```

---

*Last updated: 2026-03-31*