#!/usr/bin/env bash

## Run the commands to make it all work
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

echo $HOSTNAME > /etc/hostname

sed -ri "s|^#(statsdir /var/log/ntpstats/)|\1|" /etc/ntp.conf
sed -ri 's/^(statistics loopstats peerstats clockstats)/\1 rawstats sysstats/' /etc/ntp.conf
sed -ri '/filegen clockstats file clockstats type day enable/a filegen sysstats file sysstats type day enable' /etc/ntp.conf
sed -ri '/filegen clockstats file clockstats type day enable/a filegen rawstats file rawstats type day enable' /etc/ntp.conf
sed -ri '/# Use servers from the NTP Pool Project/,/pool ntp.ubuntu.com/d' /etc/ntp.conf
sed -ri '/# Specify one or more NTP servers./a server 127.127.1.0 prefer' /etc/ntp.conf

service ntp stop
service ntp start
service ntp status

frontail -d -p $HTTPPORT /var/log/ntpstats/rawstats

# Keep docker running
bash

