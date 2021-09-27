#!/usr/bin/env bash
source config.txt
cp template/webadmin.html.template webadmin.html
sed -i "s/IPADDR/$IPADDR:$HTTPPORT/g" webadmin.html
docker run -dit --rm \
    --name ntp \
    -h $HOSTNAME \
    -p $IPADDR:123:123/udp \
    -p $IPADDR:$HTTPPORT:$HTTPPORT \
    -v ntp:/var/log/ntpstats/ \
    -e TZ=$TZ \
    -e HTTPPORT=$HTTPPORT \
    -e HOSTNAME=$HOSTNAME \
    --cap-add=NET_ADMIN \
    toddwint/ntp
