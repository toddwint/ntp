# toddwint/ntp

## Info

<https://hub.docker.com/r/toddwint/ntp>

<https://github.com/toddwint/ntp>

NTP server for lab testing.

This image was created for lab setups where there is a need to provide an NTP server and none is available.

## Features

- Host an NTP server for clients.
- View NTP messages in a web browser ([frontail](https://github.com/mthenw/frontail))
    - tail the file
    - pause the flow
    - search through the flow
    - highlight multiple rows
- NTP log messages are persistent if you map the directory `/var/log/ntpstats`

## Sample `config.txt` file

```
TZ=UTC
IPADDR=127.0.0.1
HTTPPORT=9001
HOSTNAME=ntpsrvr
```

## Sample docker run command

```
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
```

## Sample webadmin.html.template file

See my github page (referenced above).


## Login page

Open the `webadmin.html` file.

Or just type in your browser `http://<ip_address>:<port>`

## Issues?

Make sure if you set an IP that machine has the same IP configured on an interface.
