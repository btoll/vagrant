#!/usr/bin/env bash

set -e

if [ -z "$JFROG_USERNAME" ] || [ -z "$JFROG_PASSWORD" ]
then
    echo "[ERROR] Either JFROG_USERNAME or JFROG_PASSWORD is missing."
    exit 1
fi

apt-get update
apt-get install -y \
    build-essential \
    curl \
    git \
    libmysqlclient-dev \
    libreadline-dev \
    libssl-dev \
    zlib1g-dev

su -c "source /vagrant/scripts/user.sh" vagrant

