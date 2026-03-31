#!/usr/bin/env bash

# A script to log a brief summary of system information

# make the directory if it doesn't exist
mkdir -p "/var/log/my-scripts/system-health-check"
FILE="/var/log/my-scripts/system-health-check/sys-health.log"
# make the log file if it doesn't exit
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
printf -v scriptStart "%(%Y-%m-%d %H:%M:%S)T"
log INFO "script began at $scriptStart"


log INFO "hostname:$HOSTNAME"

log INFO "kernal:$(uname -r)"

log INFO "bashversion:$BASH_VERSION"

# top -bn1 gets one snapshot
# grep filters just for cpu usage
# awk '{print 100 - $8}' : field 8 is idle%, subtract from 100 to get used%
cpu_usage=$(top -bn1 | grep "%Cpu" | awk '{print 100 - $8}')
log INFO "cpu:$cpu_usage"

# df calls for disk usage on file systems, -h makes it human readable
# awk pulls the 4th item (being the available storgage) and NR==2 makes sure the "Avail" headline isn't shown
freespace=$(df -h / | awk 'NR==2 {print $4}')
log INFO "free storage:$freespace"

# free reports the memory usage, -h makes it human readable
# NR==2 skips the header and $4 grabs the free column
freemem=$(free -h | awk 'NR==2 {print $4}')
log INFO "free memory:$freemem"

# services outside of docker
serviceNames=("tailscaled.service" "smbd.service")


# redirect to /dev/null so it won't be printed and will be deleted
if systemctl is-active docker.service > /dev/null 2>&1; then
    # checking the docker containers
    # mapfile adds new lines into an array and -t gets rid of the new line tags
    # process subsitition < <() used as to stay in current shell scope
    mapfile -t containerNames < <(docker ps --format "{{.Names}}")


    if (( ${#containerNames[@]} > 0 )); then
        for container in "${containerNames[@]}"; do 
            log INFO "active-container:$container"
        done
    else
        log INFO "no active containers"
    fi
fi

for service in "${serviceNames[@]}"; do
    # redirect to /dev/null so it won't be printed and will be deleted
    if systemctl is-active "$service" > /dev/null 2>&1; then
        log INFO "active-service:$service"
    else
        log INFO "inactive-service:$service"
    fi
done    

log INFO "last-edited:2026-03-22"
log INFO "script end"



