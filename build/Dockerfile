FROM ubuntu:focal
COPY scripts /opt/ntp/scripts
EXPOSE 123/udp
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN apt-get update \
    && \
    apt-get install -y \
    tzdata \
    iproute2 \
    ntp \
    && \
    mkdir -p /opt/ntp/data \
#    && \
#    apt-get remove -y \
#    tzdata \
#    && \
#    apt-get clean \
#    && \
#    apt-get autoremove -y \
    && \
    ln -s /etc/default/ntp /opt/ntp/data/default \
    && \
    ln -s /etc/ntp.conf /opt/ntp/data/
WORKDIR /opt/ntp/data
CMD ["/opt/ntp/scripts/startup.sh"]
