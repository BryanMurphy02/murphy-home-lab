#!/usr/bin/env bash

# script to backup server files with rsync and generate list of installed packages
# things being backed up: home directory, docker containers, /etc, generate a list of installed packages

# starting the script timer
printf -v scriptStart "%(%Y-%m-%d %H:%M:%S)T"
start=$SECONDS

# create log dir and file if not already there
LOGDIR="/var/log/backups"
FILE="/var/log/backups/backup.log"
mkdir -p "$LOGDIR"

if [ ! -f "$FILE" ]; then
    touch "$FILE"
fi

# take in something to log and append it to the log file
log(){
    # gets the logdate and -v stores it as a variable instead of printing
    # T is a printf format specifyer makes it known its a time token
    printf -v logdate "%(%Y-%m-%d %H:%M:%S)T"
    printf "[$logdate] [$1] $2\n" >> "$FILE"
}

# log the script beginning
log INFO "script began at $scriptStart"

# create the backup dir if not already there
mkdir -p "/srv/backups"
# grab the current date
printf -v logdate "%(%Y-%m-%d)T"
# make this iteration's backup dir
BACKUPDIR="/srv/backups/server-backups-$logdate"
mkdir -p "$BACKUPDIR"
log INFO "backup dir exists"



# backing up home dir
log INFO "backing up /home/bryan"
rsync -aAX --relative /home/bryan "$BACKUPDIR/"
if [ $? -eq 0 ]; then
    log INFO "/home/bryan exists and backed up"
else
    log ERROR "/home/bryan backup error"
fi

# backing up docker
log INFO "backing up docker containers"
rsync -aAX --relative /opt/docker "$BACKUPDIR/"
if [ $? -eq 0 ]; then
    log INFO "/opt/docker exists and backed up"
else
    log ERROR "/opt/docker backup error"
fi

# backing up /etc
log INFO "backing up /etc"
rsync -aAX --relative /etc "$BACKUPDIR/"
if [ $? -eq 0 ]; then
    log INFO "/etc exists and backed up"
else
    log ERROR "/etc backup error"
fi

# getting installed packages list
mkdir -p "$BACKUPDIR/packages"
log INFO "packages dir exists"
log INFO "saving installed packages list"
dpkg --get-selections > "$BACKUPDIR/packages/installed-packages.txt"
if [ $? -eq 0 ]; then
    log INFO "packages list exists and backed up"
else
    log ERROR "package list backup error"
fi


# compressing backup files
log INFO "compressing backup file"
tar -czf "$BACKUPDIR.tar.gz" -C "$(dirname "$BACKUPDIR")" "$(basename "$BACKUPDIR")"
if [ $? -eq 0 ]; then
    log INFO "backup compress success"
    rm -rf "$BACKUPDIR"
    if [ $? -eq 0 ]; then
        log INFO "uncompressed backup deleted"
    else
        log ERROR "error in deleting uncompressed backup"
    fi
else
    log ERROR "backup compress error"
fi


# delete backups that are older than two weeks
log INFO "deleting backups older than 14 days"
find /srv/backups -maxdepth 1 -name "*.tar.gz" -mtime +14 -delete
if [ $? -eq 0 ]; then
    log INFO "old backups deleted successfully"
else
    log ERROR "error in deleting old backups"
fi

log INFO "Backup size: $(du -sh "$BACKUPDIR.tar.gz" | cut -f1)"

end=$SECONDS
log INFO "total time elapsed: $(( end - start )) seconds"
log INFO "script end"