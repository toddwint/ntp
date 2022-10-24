FROM toddwint/mybaseimage
COPY app /opt/ntp
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    HTTPPORT1=8080 \
    HTTPPORT2=8081 \
    HTTPPORT3=8082 \
    HTTPPORT4=8083 \
    HOSTNAME=ntpsrvr \
    APPNAME=ntp
RUN apt-get update \
    && \
    apt-get install -y \
    ntp \
    rsyslog \
    && \
    echo $HOSTNAME > /etc/hostname \
    && \
    apt-get autoremove -y \
    && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /opt/ntp/debug
CMD ["/opt/ntp/scripts/startup.sh"]
