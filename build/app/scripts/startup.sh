#!/usr/bin/env bash

## Run the commands to make it all work
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

echo $HOSTNAME > /etc/hostname

# Extract compressed binaries and move binaries to bin
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    # Unzip frontail and tailon
    if [[ $(arch) == "x86_64" ]]; then
        gunzip /usr/local/bin/frontail.gz
    fi
    gunzip /usr/local/bin/tailon.gz

    # Copy python scripts to /usr/local/bin and make executable
    cp /opt/"$APPNAME"/scripts/menu /usr/local/bin
    chmod 775 /usr/local/bin/menu
fi

# Link scripts to debug folder as needed
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    ln -s /opt/"$APPNAME"/scripts/tail.sh /opt/"$APPNAME"/debug
    ln -s /opt/"$APPNAME"/scripts/tmux.sh /opt/"$APPNAME"/debug
    ln -s /opt/"$APPNAME"/scripts/menu /opt/"$APPNAME"/debug
fi

# Create the file /var/run/utmp or when using tmux this error will be received
# utempter: pututline: No such file or directory
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    touch /var/run/utmp
else
    truncate -s 0 /var/run/utmp
fi

# Disable rsyslog kernel logs and start rsyslogd
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    sed -Ei '/imklog/s/^([^#])/#\1/' /etc/rsyslog.conf
    sed -Ei '/immark/s/^#//' /etc/rsyslog.conf
    rm -rf /var/log/syslog
else
    truncate -s 0 /var/log/syslog
fi

# Sometimes rsyslog does not start, so start it and then try again
#service rsyslog start # ubuntu:focal
rsyslogd #ubuntu:jammy
if [ -z $(pidof rsyslogd) ]; then
    echo 'rsyslog not running'
    #service rsyslog start # ubuntu:focal
    rsyslogd #ubuntu:jammy
else
    echo 'rsyslog is running'
fi

# Link the log to the app log. Create/clear other log files.
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    mkdir -p /opt/"$APPNAME"/logs
    ln -s /var/log/syslog /opt/"$APPNAME"/logs/"$APPNAME".log
    mkdir -p /opt/"$APPNAME"/logs/ntpstats
    ln -s /var/log/ntpstats/rawstats /opt/"$APPNAME"/logs/ntpstats/rawstats
    ln -s /var/log/ntpstats/peerstats /opt/"$APPNAME"/logs/ntpstats/peerstats
    ln -s /var/log/ntpstats/loopstats /opt/"$APPNAME"/logs/ntpstats/loopstats
    ln -s /var/log/ntpstats/clockstats /opt/"$APPNAME"/logs/ntpstats/clockstats
    ln -s /var/log/ntpstats/sysstats /opt/"$APPNAME"/logs/ntpstats/sysstats
else
    truncate -s 0 /opt/"$APPNAME"/logs/ntpstats/rawstats
    truncate -s 0 /opt/"$APPNAME"/logs/ntpstats/peerstats
    truncate -s 0 /opt/"$APPNAME"/logs/ntpstats/loopstats
    truncate -s 0 /opt/"$APPNAME"/logs/ntpstats/clockstats
    truncate -s 0 /opt/"$APPNAME"/logs/ntpstats/sysstats
fi

# Print first message to either the app log file or syslog
#echo "$(date -Is) [Start of $APPNAME log file]" >> /opt/"$APPNAME"/logs/"$APPNAME".log
logger "[Start of $APPNAME log file]"

# Modify configuration files or customize container
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    # Copy templates to configuration locations
    cp /opt/"$APPNAME"/configs/ntp.conf /etc/ntp.conf
    cp /opt/"$APPNAME"/configs/tmux.conf /root/.tmux.conf

    # Create menu.json
    /opt/"$APPNAME"/scripts/make_menujson.py /opt/"$APPNAME"/scripts/menu.json
fi

# Start services
service ntp start

# Start web interface
NLINES=1000 # how many tail lines to follow
sed -Ei 's/tail -n 500/tail -n '"$NLINES"'/' /opt/"$APPNAME"/scripts/tail.sh
sed -Ei 's/tail -n 500/tail -n '"$NLINES"'/' /opt/"$APPNAME"/scripts/tmux.sh
sed -Ei 's/\$lines/'"$NLINES"'/' /opt/"$APPNAME"/configs/tailon.toml
sed -Ei '/^listen-addr = /c listen-addr = [":'"$HTTPPORT4"'"]' /opt/"$APPNAME"/configs/tailon.toml

# ttyd1 (tail and read only)
nohup ttyd \
    --port "$HTTPPORT1" \
    --client-option titleFixed="${APPNAME}.log" \
    --client-option fontSize=16 \
    --client-option 'theme={"foreground":"black","background":"white","selectionBackground":"#ff6969"}' \
    --signal 2 \
    /opt/"$APPNAME"/scripts/tail.sh \
    >> /opt/"$APPNAME"/logs/ttyd1.log 2>&1 &

# ttyd2 (tmux and interactive)
nohup ttyd \
    --writable \
    --port "$HTTPPORT2" \
    --client-option titleFixed="${APPNAME}.log" \
    --client-option fontSize=16 \
    --client-option 'theme={"foreground":"black","background":"white","selectionBackground":"#ff6969"}' \
    --signal 9 \
    /opt/"$APPNAME"/scripts/tmux.sh \
    >> /opt/"$APPNAME"/logs/ttyd2.log 2>&1 &

# frontail
if [[ $(arch) == "x86_64" ]]; then
    nohup frontail \
        -n "$NLINES" \
        -p "$HTTPPORT3" \
        /opt/"$APPNAME"/logs/"$APPNAME".log \
        /opt/"$APPNAME"/logs/ntpstats/rawstats \
        /opt/"$APPNAME"/logs/ntpstats/peerstats \
        /opt/"$APPNAME"/logs/ntpstats/loopstats \
        /opt/"$APPNAME"/logs/ntpstats/clockstats \
        /opt/"$APPNAME"/logs/ntpstats/sysstats \
        >> /opt/"$APPNAME"/logs/frontail.log 2>&1 &
fi

# tailon
nohup tailon \
    -c /opt/"$APPNAME"/configs/tailon.toml \
    /opt/"$APPNAME"/logs/"$APPNAME".log \
    /opt/"$APPNAME"/logs/ntpstats/rawstats \
    /opt/"$APPNAME"/logs/ntpstats/peerstats \
    /opt/"$APPNAME"/logs/ntpstats/loopstats \
    /opt/"$APPNAME"/logs/ntpstats/clockstats \
    /opt/"$APPNAME"/logs/ntpstats/sysstats \
    /opt/"$APPNAME"/logs/ttyd1.log \
    /opt/"$APPNAME"/logs/ttyd2.log \
    /opt/"$APPNAME"/logs/frontail.log \
    /opt/"$APPNAME"/logs/tailon.log \
    >> /opt/"$APPNAME"/logs/tailon.log 2>&1 &

# Remove the .firstrun file if this is the first run
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    rm -f /opt/"$APPNAME"/scripts/.firstrun
fi

# Keep docker running
bash
