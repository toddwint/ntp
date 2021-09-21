#!/usr/bin/env bash

##
## example environment variables can be found in the .env file
##
##

## Run the commands to make it all work
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

service ntp start
service ntp status

# Keep docker running
bash

