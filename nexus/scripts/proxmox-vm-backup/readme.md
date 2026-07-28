# proxmox-vm-backup

A portable, no-frills manual backup script for Proxmox VMs and containers.

Built for setups where backups go to an external drive that isn't always
connected, so a scheduled built-in backup job isn't practical. Wraps
Proxmox's own `vzdump` tool (the same engine behind the GUI backups), so you
still get proper snapshot-mode backups, compression, and config preservation
— just triggered manually, on whichever node you plug the drive into.

## Why not just use the built-in Proxmox backup scheduler?

You can, if your backup destination is always available. This script exists
for the opposite case: an external drive that's only occasionally attached.
A scheduled job would just fail (or silently write to the wrong path) when
the drive isn't plugged in. This script checks that the destination is
actually mounted before doing anything, and is meant to be run by hand (or
triggered, e.g. via a udev rule) when the drive is connected.

## What it does

- Backs up a single VM/container, or all of them, using `vzdump` in
  snapshot mode with zstd compression.
- Writes each run's archives into `<destination>/YYYY-MM-DD/`, so if you run
  the script on multiple nodes on the same day, all of those backups land in
  one shared dated folder rather than being scattered.
- Names each archive with both the guest's ID and its current name — e.g.
  `vzdump-qemu-102-nexus-minecraft-2026_07_27-18_30_00.vma.zst` — so you can
  tell what a backup is at a glance instead of cross-referencing IDs. The
  name is looked up from the guest's own config (`qm config` / `pct config`)
  at backup time, so a rename in Proxmox is always reflected correctly.
- Writes the backup archive, `vzdump`'s temporary working files, **and**
  this script's own run log all to the destination path — nothing is left
  behind on the Proxmox node's local storage.
- Shows live progress as the backup runs.
- Optionally prunes old backups per guest, keeping only the N most recent.
- Works identically on any Proxmox node — point it at wherever the drive is
  mounted on that particular host.

## Requirements

- Must be run as root (or via `sudo`) on a Proxmox VE host.
- The destination path must already be mounted before you run the script.
  This script does not mount drives for you — set up a stable mount point
  (fstab entry by UUID, or a udev auto-mount rule) so the path is
  consistent.
- Guests must be on storage that supports snapshots (LVM-thin, ZFS, etc.)
  for `--mode snapshot` to work. If yours doesn't, see
  [Adjusting backup mode](#adjusting-backup-mode) below.

## Usage

### Interactive

```bash
sudo ./proxmox-backup.sh
```

Lists your VMs and containers, lets you pick one (or "all"), then prompts
for the destination path and how many backups to retain.

### Non-interactive / scriptable

```bash
sudo ./proxmox-backup.sh <VMID|all> <destination_path> [retention_count]
```

Examples:

```bash
# Back up VM 101 to the external drive, keep every backup
sudo ./proxmox-backup.sh 101 /mnt/external-hdd/pve-backups

# Back up everything, keep only the 3 most recent backups per guest
sudo ./proxmox-backup.sh all /mnt/external-hdd/pve-backups 3
```

## Keeping a copy on the external drive itself

Since the same script needs to work from whichever node the drive is
plugged into, it's worth keeping a copy of this repo on the drive so you
always have it available even offline:

```bash
# On any machine with the drive mounted:
git clone https://github.com/<you>/proxmox-vm-backup.git /mnt/external-hdd/proxmox-vm-backup

# On a Proxmox node with the drive attached, but no internet access:
git clone /mnt/external-hdd/proxmox-vm-backup /root/proxmox-vm-backup
cd /root/proxmox-vm-backup
sudo ./proxmox-backup.sh
```

Just remember to `git pull` on the drive's copy periodically if you make
changes elsewhere, so nodes cloning from it stay up to date.

## Adjusting backup mode

The script uses `--mode snapshot` by default (no VM downtime, needs
snapshot-capable storage). If your storage doesn't support snapshots,
change the `--mode snapshot` flags in `proxmox-backup.sh` to:

- `--mode suspend` — briefly pauses the guest during backup
- `--mode stop` — shuts the guest down for the duration of the backup

## Logs

Each run's log is written to `<destination>/logs/proxmox-backup.log` on
the external drive rather than on the node, so history travels with your
backups regardless of which node ran them.

## License

MIT — see [LICENSE](LICENSE).