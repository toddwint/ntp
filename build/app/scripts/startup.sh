#!/usr/bin/env bash

## Run the commands to make it all work
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

echo $HOSTNAME > /etc/hostname

# Extract compressed binaries and move binaries to bin
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    # Unzip frontail and tailon
    gunzip /usr/local/bin/frontail.gz
    gunzip /usr/local/bin/tailon.gz
fi

# Link scripts to debug folder as needed
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    ln -s /opt/"$APPNAME"/scripts/tail.sh /opt/"$APPNAME"/debug
    ln -s /opt/"$APPNAME"/scripts/tmux.sh /opt/"$APPNAME"/debug
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
service rsyslog start
if [ -z $(pidof rsyslogd) ]; then 
    echo 'rsyslog not running'
    service rsyslog start
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
fi

# Print first message to either the app log file or syslog
#echo "$(date -Is) [Start of $APPNAME log file]" >> /opt/"$APPNAME"/logs/"$APPNAME".log
logger "[Start of $APPNAME log file]"

if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    # Copy templates to configuration locations
    cp /opt/"$APPNAME"/configs/ntp.conf /etc/ntp.conf
fi

# Start services
service ntp start

# Start web interface
NLINES=1000
cp /opt/"$APPNAME"/configs/tmux.conf /root/.tmux.conf
sed -Ei 's/tail -n 500/tail -n '"$NLINES"'/' /opt/"$APPNAME"/scripts/tail.sh
# ttyd tail with color and read only
nohup ttyd -p "$HTTPPORT1" -R -t titleFixed="${APPNAME}.log" -t fontSize=16 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tail.sh >> /opt/"$APPNAME"/logs/ttyd1.log 2>&1 &
# ttyd tail without color and read only
#nohup ttyd -p "$HTTPPORT1" -R -t titleFixed="${APPNAME}.log" -T xterm-mono -t fontSize=16 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tail.sh >> /opt/"$APPNAME"/logs/ttyd1.log 2>&1 &
sed -Ei 's/tail -n 500/tail -n '"$NLINES"'/' /opt/"$APPNAME"/scripts/tmux.sh
# ttyd tmux with color
nohup ttyd -p "$HTTPPORT2" -t titleFixed="${APPNAME}.log" -t fontSize=16 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tmux.sh >> /opt/"$APPNAME"/logs/ttyd2.log 2>&1 &
# ttyd tmux without color
#nohup ttyd -p "$HTTPPORT2" -t titleFixed="${APPNAME}.log" -T xterm-mono -t fontSize=16 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tmux.sh >> /opt/"$APPNAME"/logs/ttyd2.log 2>&1 &
nohup frontail -n "$NLINES" -p "$HTTPPORT3" /opt/"$APPNAME"/logs/"$APPNAME".log /opt/"$APPNAME"/logs/ntpstats/* >> /opt/"$APPNAME"/logs/frontail.log 2>&1 &
sed -Ei 's/\$lines/'"$NLINES"'/' /opt/"$APPNAME"/configs/tailon.toml
sed -Ei '/^listen-addr = /c listen-addr = [":'"$HTTPPORT4"'"]' /opt/"$APPNAME"/configs/tailon.toml
nohup tailon -c /opt/"$APPNAME"/configs/tailon.toml /opt/"$APPNAME"/logs/"$APPNAME".log /opt/"$APPNAME"/logs/ntpstats/rawstats /opt/"$APPNAME"/logs/ntpstats/peerstats /opt/"$APPNAME"/logs/ntpstats/loopstats /opt/"$APPNAME"/logs/ntpstats/clockstats /opt/"$APPNAME"/logs/ntpstats/sysstats /opt/"$APPNAME"/logs/ttyd1.log /opt/"$APPNAME"/logs/ttyd2.log /opt/"$APPNAME"/logs/frontail.log /opt/"$APPNAME"/logs/tailon.log >> /opt/"$APPNAME"/logs/tailon.log 2>&1 &

# Remove the .firstrun file if this is the first run
if [ -e /opt/"$APPNAME"/scripts/.firstrun ]; then
    rm -f /opt/"$APPNAME"/scripts/.firstrun
fi

# Keep docker running
bash
