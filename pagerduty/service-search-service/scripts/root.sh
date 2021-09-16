#!/usr/bin/env bash

set -e

apt-get update
apt-get install -y \
    autoconf \
    automake \
    build-essential \
    libncurses5-dev \
    libssl-dev \
    unzip

# Install Docker Community Edition.
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
apt-get update
apt-get install -y docker-ce
service docker restart
usermod -aG docker vagrant

# Install Docker Compose.
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

su -c "source /vagrant/scripts/user.sh" vagrant

