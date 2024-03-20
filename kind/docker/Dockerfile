# Note must be root for iptables and the container must be given
# NET_ADMIN capabilities.

FROM debian:bookworm-slim

#RUN groupadd --gid 1000 noroot \
#    && useradd \
#    --create-home \
#    --home-dir /home/noroot \
#    --uid 1000 \
#    --gid 1000 \
#    # https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
#    --no-log-init noroot

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        dnsutils \
        gdb \
        git \
        gzip \
        iperf3 \
        iproute2 \
        iptables \
        iputils-ping \
        iputils-tracepath \
        openssl \
        strace \
        tar \
        tree \
        vim \
        wget \
        whois

#USER noroot
#WORKDIR /home/noroot

