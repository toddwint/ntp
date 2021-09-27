FROM ubuntu:focal
COPY scripts /opt/ntp/scripts
EXPOSE 123/udp 9001
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    HTTPPORT=9001 \
    HOSTNAME=ntpsrvr
RUN apt-get update \
    && \
    apt-get install -y \
    tzdata \
    iproute2 \
    wget \
    ntp \
    && \
    echo $HOSTNAME > /etc/hostname \
    && \
    wget -q https://github.com/mthenw/frontail/releases/download/v4.9.1/frontail-linux -O /usr/local/bin/frontail \
    && \
    chmod 755 /usr/local/bin/frontail \
    && \
    apt-get remove -y \
    wget \
    && \
    apt-get autoremove -y \
    && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /opt/ntp/
CMD ["/opt/ntp/scripts/startup.sh"]
