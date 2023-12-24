---
title: README
date: 2023-12-21
---

# toddwint/ntp


## Info

`ntp` docker image for simple lab testing applications.

Docker Hub: <https://hub.docker.com/r/toddwint/ntp>

GitHub: <https://github.com/toddwint/ntp>


## Overview

Docker image for hosting an NTP server fudging a stratum 0.

Pull the docker image from Docker Hub or, optionally, build the docker image from the source files in the `build` directory.

Create and run the container using `docker run` commands, `docker compose` commands, or by downloading and using the files here on github in the directories `run` or `compose`.

Manage the container using a web browser. Navigate to the IP address of the container and one of the `HTTPPORT`s.

**NOTE: Network interface must be UP i.e. a cable plugged in.**

Example `docker run` and `docker compose` commands as well as sample commands to create the macvlan are below.


## Features

- Ubuntu base image
- Plus:
  - fzf
  - iproute2
  - iputils-ping
  - ntp
  - python3-minimal
  - rsyslog
  - tmux
  - tzdata
  - [ttyd](https://github.com/tsl0922/ttyd)
    - View the terminal in your browser
  - [frontail](https://github.com/mthenw/frontail)
    - View logs in your browser
    - Mark/Highlight logs
    - Pause logs
    - Filter logs
  - [tailon](https://github.com/gvalkov/tailon)
    - View multiple logs and files in your browser
    - User selectable `tail`, `grep`, `sed`, and `awk` commands
    - Filter logs and files
    - Download logs to your computer


## Sample commands to create the `macvlan`

Create the docker macvlan interface.

```bash
docker network create -d macvlan --subnet=192.168.10.0/24 --gateway=192.168.10.254 \
    --aux-address="mgmt_ip=192.168.10.2" -o parent="eth0" \
    --attachable "ntp01"
```

Create a management macvlan interface.

```bash
sudo ip link add "ntp01" link "eth0" type macvlan mode bridge
sudo ip link set "ntp01" up
```

Assign an IP on the management macvlan interface plus add routes to the docker container.

```bash
sudo ip addr add "192.168.10.2/32" dev "ntp01"
sudo ip route add "192.168.10.0/24" dev "ntp01"
```


## Sample `docker run` command

```bash
docker run -dit \
    --name "ntp01" \
    --network "ntp01" \
    --ip "192.168.10.1" \
    -h "ntp01" \
    -p "192.168.10.1:123:123/udp" \
    -p "192.168.10.1:8080:8080" \
    -p "192.168.10.1:8081:8081" \
    -p "192.168.10.1:8082:8082" \
    -p "192.168.10.1:8083:8083" \
    -e TZ="UTC" \
    -e MGMTIP="192.168.10.2" \
    -e GATEWAY="192.168.10.254" \
    -e HTTPPORT1="8080" \
    -e HTTPPORT2="8081" \
    -e HTTPPORT3="8082" \
    -e HTTPPORT4="8083" \
    -e HOSTNAME="ntp01" \
    -e APPNAME="ntp" \
    --cap-add=NET_ADMIN \
    "toddwint/ntp"
```


## Sample `docker compose` (`compose.yaml`) file

```yaml
name: ntp01

services:
  ntp:
    image: toddwint/ntp
    hostname: ntp01
    ports:
        - "192.168.10.1:123:123/udp"
        - "192.168.10.1:8080:8080"
        - "192.168.10.1:8081:8081"
        - "192.168.10.1:8082:8082"
        - "192.168.10.1:8083:8083"
    networks:
        default:
            ipv4_address: 192.168.10.1
    environment:
        - MGMTIP=192.168.10.2
        - GATEWAY=192.168.10.254
        - HOSTNAME=ntp01
        - TZ=UTC
        - HTTPPORT1=8080
        - HTTPPORT2=8081
        - HTTPPORT3=8082
        - HTTPPORT4=8083
        - APPNAME=ntp
    privileged: true
    cap_add:
      - NET_ADMIN
    tty: true

networks:
    default:
        name: "ntp01"
        external: true
```
