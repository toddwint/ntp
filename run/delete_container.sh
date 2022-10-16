#!/usr/bin/env bash
source "$(dirname "$(realpath $0)")"/config.txt
docker container stop "$HOSTNAME"
docker container rm "$HOSTNAME"
htmlfile="$(dirname "$(realpath $0)")"/webadmin.html
rm -rf "$htmlfile"
