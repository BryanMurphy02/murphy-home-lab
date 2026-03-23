#!/usr/bin/env bash

# A script to output a brief summary of system information

# top -bn1 gets one snapshot
# grep filters just for cpu usage
# awk '{print 100 - $8}' : field 8 is idle%, subtract from 100 to get used%
cpu_usage=$(top -bn1 | grep "%Cpu" | awk '{print 100 - $8}')

# df calls for disk usage on file systems, -h makes it human readable
# awk pulls the 4th item (being the available storgage) and NR==2 makes sure the "Avail" headline isn't shown
freespace=$(df -h / | awk 'NR==2 {print $4}')

# free reports the memory usage, -h makes it human readable
# NR==2 skips the header and $4 grabs the free column
freemem=$(free -h | awk 'NR==2 {print $4}')

# services outside of docker
serviceNames=("tailscaled.service" "smbd.service")

# styling
greentext="\033[32m"
redtext="\033[31m"
bold="\033[1m"
normal="\033[0m"

# gets the logdate and -v stores it as a variable instead of printing
# T is a printf format specifyer makes it known its a time token
printf -v logdate "%(%Y-%m-%d %H:%M:%S)T"

echo -e "$bold Quick system report for: $greentext$HOSTNAME$normal"
printf "\tKernel Release:\t%s\n" "$(uname -r)"
printf "\tBash Version:\t%s\n" "$BASH_VERSION"
printf "\tRunning as:\t%s\n" "$USER"
printf "\tCPU Usage:\t%s\n" "$cpu_usage%"
printf "\tFree Storage:\t%s\n" "$freespace"
printf "\tFree Memory:\t%s\n" "$freemem"

printf "\n"

# redirect to /dev/null so it won't be printed and will be deleted
if systemctl is-active docker.service > /dev/null 2>&1; then
    # checking the docker containers
    # mapfile adds new lines into an array and -t gets rid of the new line tags
    # process subsitition < <() used as to stay in current shell scope
    mapfile -t containerNames < <(docker ps --format "{{.Names}}")


    if (( ${#containerNames[@]} > 0 )); then
        printf "\tActive Docker Containers:\n"
        for container in "${containerNames[@]}"; do 
            printf "\t\t%b\n" "${greentext}${container}${normal}"
        done
    else
        printf "\tNo Active Docker Containers\n"
    fi
fi

printf "\tOther Active Services:\n"
for service in "${serviceNames[@]}"; do
    # redirect to /dev/null so it won't be printed and will be deleted
    if systemctl is-active "$service" > /dev/null 2>&1; then
        printf "\t\t%b\n" "${greentext}${service}${normal}"
    else
        printf "\t\t%b\n" "${redtext}${service}${normal}"
    fi
done    

printf "\n"

printf "\tGenerated on:\t%s\n" "$logdate"
printf "\tLast edited:\t%s\n" "2026-03-22"



