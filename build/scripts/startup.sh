#!/usr/bin/env bash

## Run the commands to make it all work
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

echo $HOSTNAME > /etc/hostname

# Unzip frontail and tailon
gunzip /usr/local/bin/frontail.gz
gunzip /usr/local/bin/tailon.gz

# Disable rsyslog kernel logs and start rsyslogd
sed -Ei '/imklog/s/^[^#]/#/' /etc/rsyslog.conf
sed -Ei '/immark/s/^#//' /etc/rsyslog.conf
# Start rsyslogd with the binary name or the service way?
#rsyslogd
service rsyslog start
service rsyslog status

# Configure ntp settings
cp /opt/"$APPNAME"/scripts/ntp.conf /etc/ntp.conf

# Start the ntp service
service ntp stop
service ntp start
service ntp status

# Link the log to the app log
mkdir -p /opt/"$APPNAME"/logs/ntpstats
ln -s /var/log/syslog /opt/"$APPNAME"/logs/"$APPNAME".log
ln -s /var/log/ntpstats/rawstats /opt/"$APPNAME"/logs/ntpstats/rawstats
ln -s /var/log/ntpstats/peerstats /opt/"$APPNAME"/logs/ntpstats/peerstats
ln -s /var/log/ntpstats/loopstats /opt/"$APPNAME"/logs/ntpstats/loopstats
ln -s /var/log/ntpstats/clockstats /opt/"$APPNAME"/logs/ntpstats/clockstats
ln -s /var/log/ntpstats/sysstats /opt/"$APPNAME"/logs/ntpstats/sysstats
#ln /var/log/remote/syslog.log /opt/"$APPNAME"/logs/"$APPNAME".log

# Create logs folder and init files
mkdir -p /opt/"$APPNAME"/logs/ntpstats
touch /opt/"$APPNAME"/logs/"$APPNAME".log
truncate -s 0 /opt/"$APPNAME"/logs/"$APPNAME".log
#echo "$(date -Is) [Start of $APPNAME log file]" >> /opt/"$APPNAME"/logs/"$APPNAME".log
logger "$(date -Is) [Start of $APPNAME log file]"

# Start web interface
NLINES=1000
cp /opt/"$APPNAME"/scripts/tmux.conf /root/.tmux.conf
sed -Ei 's/tail -n 500/tail -n '"$NLINES"'/' /opt/"$APPNAME"/scripts/tail.sh
# ttyd tail with color and read only
nohup ttyd -p "$HTTPPORT1" -R -t titleFixed="${APPNAME}|${APPNAME}.log" -t fontSize=18 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tail.sh >> /opt/"$APPNAME"/logs/ttyd1.log 2>&1 &
# ttyd tail without color and read only
#nohup ttyd -p "$HTTPPORT1" -R -t titleFixed="${APPNAME}|${APPNAME}.log" -T xterm-mono -t fontSize=18 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tail.sh >> /opt/"$APPNAME"/logs/ttyd1.log 2>&1 &
sed -Ei 's/tail -n 500/tail -n '"$NLINES"'/' /opt/"$APPNAME"/scripts/tmux.sh
# ttyd tmux with color
nohup ttyd -p "$HTTPPORT2" -t titleFixed="${APPNAME}|${APPNAME}.log" -t fontSize=18 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tmux.sh >> /opt/"$APPNAME"/logs/ttyd2.log 2>&1 &
# ttyd tmux without color
#nohup ttyd -p "$HTTPPORT2" -t titleFixed="${APPNAME}|${APPNAME}.log" -T xterm-mono -t fontSize=18 -t 'theme={"foreground":"black","background":"white", "selection":"red"}' /opt/"$APPNAME"/scripts/tmux.sh >> /opt/"$APPNAME"/logs/ttyd2.log 2>&1 &
nohup frontail -n "$NLINES" -p "$HTTPPORT3" /opt/"$APPNAME"/logs/"$APPNAME".log /opt/"$APPNAME"/logs/ntpstats/* >> /opt/"$APPNAME"/logs/frontail.log 2>&1 &
sed -Ei 's/\$lines/'"$NLINES"'/' /opt/"$APPNAME"/scripts/tailon.toml
sed -Ei '/^listen-addr = /c listen-addr = [":'"$HTTPPORT4"'"]' /opt/"$APPNAME"/scripts/tailon.toml
nohup tailon -c /opt/"$APPNAME"/scripts/tailon.toml /opt/"$APPNAME"/logs/"$APPNAME".log /opt/"$APPNAME"/logs/ntpstats/rawstats /opt/"$APPNAME"/logs/ntpstats/peerstats /opt/"$APPNAME"/logs/ntpstats/loopstats /opt/"$APPNAME"/logs/ntpstats/clockstats /opt/"$APPNAME"/logs/ntpstats/sysstats /opt/"$APPNAME"/logs/ttyd1.log /opt/"$APPNAME"/logs/ttyd2.log /opt/"$APPNAME"/logs/frontail.log /opt/"$APPNAME"/logs/tailon.log >> /opt/"$APPNAME"/logs/tailon.log 2>&1 &

# Keep docker running
bash
