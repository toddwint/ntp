# toddwint/ntp

## Info

Simple NTP server for lab testing.

This image was created for lab setups where there is a need to provide an NTP server and none is available.

## Sample `config.txt` file

```
TZ=UTC
IPADDR=10.1.233.88
```

## Sample docker run command

```
#!/usr/bin/env bash
source config.txt
docker run -dit --rm \
    --name ntp \
    -p $IPADDR:123:123/udp \
    -v ntp:/opt/ntp/ \
    -e TZ=$TZ \
    --cap-add=NET_ADMIN \
    toddwint/ntp
```

## Verify it is working

### From the docker container

```
ss -ln
```

Verify you see a service listening on port 123

- - -

```
service ntp status
```

Verify the service has started


### From a linux client

First make sure you have ntpdate installed.  If not install it `sudo apt-get install ntpdate`

```
ntpdate -q <ip of container>
```
