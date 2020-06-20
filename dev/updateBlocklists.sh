#!/bin/bash

mkdir -p /tmp/svpihole
cd /tmp/svpihole
mkdir -p /var/log/svpihole

logfile="/var/log/svpihole/updateBlocklists.sh"
blocklists="https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten.md"


#Description: writeLog() - print logs
writeLog(){
    echo -e '['$(date +'%Y-%m-%d %H:%M:%S')']' $* | tee -a $logfile
}

# Check internet connection
ping -c1 8.8.8.8 | tee -a $logfile
if [ $? -ne 0 ]
then
    writeLog "Connection check failed"
    exit 1
fi

# Get latest blocklists
curl $blocklists | grep "\*" | cut -f2 -d' ' | sort -u > adlists.list
if [ $? -ne 0 ]
then
    writeLog "Downloading latest blocklists failed."
    exit 1
fi

# Replace list to pihole directory
rm /etc/pihole/adlists.list
mv adlists.list /etc/pihole

# Update pihole-database
pihole -g