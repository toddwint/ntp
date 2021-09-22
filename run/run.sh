#!/usr/bin/env bash
source config.txt
docker run -dit --rm \
    --name ntp \
    -p $IPADDR:123:123/udp \
    -v ntp:/opt/ntp/ \
    -e TZ=$TZ \
    --cap-add=NET_ADMIN \
    toddwint/ntp
