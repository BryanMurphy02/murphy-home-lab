#!/bin/bash
#
# proxmox-backup.sh
#
# Portable manual backup script for Proxmox VMs/containers.
# Designed to run on any Proxmox node, backing up to an external drive
# (or any writable path) with nothing written to local node storage.
#
# Backups are written into a folder named for today's date
# (<destination>/YYYY-MM-DD/), so multiple nodes backing up on the same day
# all land in the same shared folder.
#
# Archive filenames include both the guest's ID and its current name, e.g.
# vzdump-qemu-102-nexus-minecraft-2026_07_27-18_30_00.vma.zst — so you can
# identify a backup at a glance without cross-referencing IDs.
#
# Usage (non-interactive / scriptable):
#   ./proxmox-backup.sh <VMID|all> <destination_path> [retention_count]
#
# Usage (interactive):
#   ./proxmox-backup.sh
#     -> prompts you to pick a VM/CT from a list, then prompts for the
#        destination path (tab-completion supported).
#
# Examples:
#   ./proxmox-backup.sh 101 /mnt/external-hdd/pve-backups
#   ./proxmox-backup.sh all /mnt/external-hdd/pve-backups 3
#
# Requirements:
#   - Run as root (or via sudo) on the Proxmox host.
#   - The destination must already be mounted (this script does not mount
#     drives for you).

set -euo pipefail

# --- Root / vzdump checks (needed before we can even list VMs) -----------

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root." >&2
    exit 1
fi

if ! command -v vzdump >/dev/null 2>&1; then
    echo "ERROR: vzdump not found. Is this running on a Proxmox host?" >&2
    exit 1
fi

# --- Interactive mode: no args given ---------------------------------------

VMID="${1:-}"
DEST="${2:-}"
RETENTION="${3:-0}"

if [ -z "$VMID" ]; then
    echo "== Proxmox Backup: interactive mode =="
    echo
    echo "Available guests:"
    echo

    declare -a GUEST_IDS
    i=1

    while IFS= read -r line; do
        gid=$(echo "$line" | awk '{print $1}')
        [[ "$gid" =~ ^[0-9]+$ ]] || continue
        name=$(echo "$line" | awk '{print $2}')
        status=$(echo "$line" | awk '{print $3}')
        echo "  [$i] VM  $gid  ($name, $status)"
        GUEST_IDS[$i]="$gid"
        i=$((i + 1))
    done < <(qm list 2>/dev/null | tail -n +2)

    while IFS= read -r line; do
        gid=$(echo "$line" | awk '{print $1}')
        [[ "$gid" =~ ^[0-9]+$ ]] || continue
        name=$(echo "$line" | awk '{print $3}')
        status=$(echo "$line" | awk '{print $2}')
        echo "  [$i] CT  $gid  ($name, $status)"
        GUEST_IDS[$i]="$gid"
        i=$((i + 1))
    done < <(pct list 2>/dev/null | tail -n +2)

    echo "  [a] All VMs and containers"
    echo
    read -r -p "Select a guest to back up: " choice

    if [ "$choice" == "a" ]; then
        VMID="all"
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ -n "${GUEST_IDS[$choice]:-}" ]; then
        VMID="${GUEST_IDS[$choice]}"
    else
        echo "ERROR: Invalid selection." >&2
        exit 1
    fi

    echo
    read -e -r -p "Destination path (external drive mount point): " DEST

    read -r -p "Backups to keep per guest at this destination [0 = keep all]: " RETENTION
    RETENTION="${RETENTION:-0}"
fi

if [ -z "$DEST" ]; then
    echo "ERROR: Destination path is required." >&2
    exit 1
fi

# --- Destination checks -----------------------------------------------------

if [ ! -d "$DEST" ]; then
    echo "ERROR: Destination '$DEST' does not exist. Is the external drive mounted?" >&2
    exit 1
fi

if ! mountpoint -q "$DEST" 2>/dev/null; then
    echo "WARNING: '$DEST' does not appear to be a mount point itself. Double-check the drive is actually mounted there and this isn't local node storage." >&2
fi

if [ ! -w "$DEST" ]; then
    echo "ERROR: Destination '$DEST' is not writable." >&2
    exit 1
fi

FREE_KB=$(df --output=avail "$DEST" | tail -1)
FREE_GB=$(( FREE_KB / 1024 / 1024 ))

# --- Set up destination-side working paths (nothing touches local disk) ---

# All backups from today, from any node, land in the same dated folder.
DATE_DIR="$DEST/$(date +%Y-%m-%d)"
DUMPDIR="$DATE_DIR"
TMPDIR="$DEST/.vzdump-tmp"
LOGDIR="$DEST/logs"

mkdir -p "$DUMPDIR" "$TMPDIR" "$LOGDIR"
LOGFILE="$LOGDIR/proxmox-backup.log"

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOGFILE"
}

log "== Backup run starting =="
log "Node: $(hostname)"
log "Target: $VMID -> $DUMPDIR"
log "(shared date folder — other nodes backing up today land here too)"
log "Free space: ${FREE_GB}GB"

if [ "$FREE_GB" -lt 20 ]; then
    log "WARNING: Only ${FREE_GB}GB free on '$DEST'."
fi

# --- Run backup, forcing line-buffered output so progress streams live ----

# Marker file so we can later identify exactly which archives this run
# produced (needed since re-runs on the same day share a dated folder).
START_MARKER="$DEST/.backup-start-marker"
touch "$START_MARKER"

# Build the list of guest IDs this run is targeting, so we can look up
# their names afterward for renaming.
declare -a TARGET_IDS
if [ "$VMID" == "all" ]; then
    readarray -t TARGET_IDS < <(
        { qm list 2>/dev/null | tail -n +2 | awk '{print $1}'
          pct list 2>/dev/null | tail -n +2 | awk '{print $1}'; } | grep -E '^[0-9]+$'
    )
else
    TARGET_IDS=("$VMID")
fi

set +e
if [ "$VMID" == "all" ]; then
    stdbuf -oL -eL vzdump --all --mode snapshot --compress zstd \
        --dumpdir "$DUMPDIR" --tmpdir "$TMPDIR" 2>&1 | tee -a "$LOGFILE"
    STATUS=${PIPESTATUS[0]}
else
    stdbuf -oL -eL vzdump "$VMID" --mode snapshot --compress zstd \
        --dumpdir "$DUMPDIR" --tmpdir "$TMPDIR" 2>&1 | tee -a "$LOGFILE"
    STATUS=${PIPESTATUS[0]}
fi
set -e

# Clean up the temp working dir regardless of outcome
rmdir "$TMPDIR" 2>/dev/null || true

if [ "$STATUS" -ne 0 ]; then
    log "ERROR: vzdump exited with status $STATUS"
    exit "$STATUS"
fi

log "Backup completed successfully."

# --- Rename archives to include the guest's name, not just its ID ---------
# vzdump has no built-in option for this, so we rename after the fact.
# Result: vzdump-qemu-102-nexus-minecraft-2026_07_27-18_30_00.vma.zst

get_guest_name() {
    local id="$1"
    local name
    name=$(qm config "$id" 2>/dev/null | awk -F': ' '/^name:/ {print $2}')
    if [ -z "$name" ]; then
        name=$(pct config "$id" 2>/dev/null | awk -F': ' '/^hostname:/ {print $2}')
    fi
    echo "$name"
}

sanitize_name() {
    # Keep it filesystem-safe (exFAT/ext4/NTFS friendly): letters, numbers,
    # dots, dashes, underscores only.
    echo "$1" | tr -c 'A-Za-z0-9._-' '-' | sed 's/-\{2,\}/-/g; s/^-//; s/-$//'
}

for gid in "${TARGET_IDS[@]}"; do
    guest_name=$(get_guest_name "$gid")
    if [ -z "$guest_name" ]; then
        log "Note: could not determine a name for guest $gid, leaving its filename as-is."
        continue
    fi
    safe_name=$(sanitize_name "$guest_name")
    [ -z "$safe_name" ] && continue

    for prefix in vzdump-qemu vzdump-lxc; do
        ext="vma.zst"
        [ "$prefix" == "vzdump-lxc" ] && ext="tar.zst"

        archive=$(find "$DUMPDIR" -maxdepth 1 -newer "$START_MARKER" \
            -name "${prefix}-${gid}-*.${ext}" 2>/dev/null | head -n1)
        [ -z "$archive" ] && continue

        newarchive="${archive/${prefix}-${gid}-/${prefix}-${gid}-${safe_name}-}"
        if [ "$archive" != "$newarchive" ] && [ ! -e "$newarchive" ]; then
            mv "$archive" "$newarchive"
            log "Renamed: $(basename "$archive") -> $(basename "$newarchive")"

            base="${archive%.$ext}"
            newbase="${newarchive%.$ext}"
            for sidecar_ext in log notes; do
                if [ -f "${base}.${sidecar_ext}" ]; then
                    mv "${base}.${sidecar_ext}" "${newbase}.${sidecar_ext}"
                fi
            done
        fi
    done
done

rm -f "$START_MARKER"

# --- Optional pruning -----------------------------------------------------
# Keeps only the N most recent backup archives per guest ID, searching across
# ALL dated subfolders under the destination (since a guest's backups are now
# spread across e.g. 2026-07-27/, 2026-07-28/, etc.).
# Handles both VM (vzdump-qemu-*) and container (vzdump-lxc-*) naming.

if [ "$RETENTION" -gt 0 ] 2>/dev/null; then
    log "Pruning old backups, keeping $RETENTION most recent per guest..."

    for prefix in vzdump-qemu vzdump-lxc; do
        ids=$(find "$DEST" -mindepth 2 -maxdepth 2 -type f -name "${prefix}-*" 2>/dev/null \
            | grep -oP "(?<=${prefix}-)[0-9]+" | sort -u || true)

        for gid in $ids; do
            # Newest first, based on modification time, across all date folders
            files=$(find "$DEST" -mindepth 2 -maxdepth 2 -type f \
                \( -name "${prefix}-${gid}-*.vma.zst" -o -name "${prefix}-${gid}-*.tar.zst" \) \
                -printf '%T@ %p\n' 2>/dev/null | sort -rn | cut -d' ' -f2- || true)
            count=$(echo "$files" | grep -c . || true)

            if [ "$count" -gt "$RETENTION" ]; then
                echo "$files" | tail -n +"$((RETENTION + 1))" | while read -r old_file; do
                    [ -z "$old_file" ] && continue
                    log "Removing old backup: $old_file"
                    base="${old_file%.vma.zst}"
                    base="${base%.tar.zst}"
                    rm -f "$old_file" "${base}.log" "${base}.notes" 2>/dev/null || true
                done
            fi
        done
    done

    # Clean up any date folders that are now empty
    find "$DEST" -mindepth 1 -maxdepth 1 -type d -regex '.*/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' -empty -delete 2>/dev/null || true
fi

log "== Backup run finished =="