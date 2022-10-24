#!/usr/bin/env bash
source "$(dirname "$(realpath $0)")"/config.txt
docker container stop "$HOSTNAME"
docker container rm "$HOSTNAME"
IPASSIGNED=$(ip addr show $INTERFACE | grep $IPADDR)
if [ -n "$IPASSIGNED" ]; then
   SETIP="$IPADDR/$(echo $SUBNET | awk -F/ '{print $2}')" 
   sudo ip addr del $SETIP dev $INTERFACE
else
    echo 'IP is not assigned to the interface'
fi
htmlfile="$(dirname "$(realpath $0)")"/webadmin.html
rm -rf "$htmlfile"
