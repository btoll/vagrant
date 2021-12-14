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

# Linux doesn't need to use `dnsmasq` (ignore https://github.com/PagerDuty/web#install-and-setup-dnsmasq-server).
# Instead, add to `/etc/hosts`.
(
    echo "127.0.0.1     pagerduty.dev" ;
    echo "127.0.0.1     pagerduty.net" ;
    echo "127.0.0.1     mysql.pagerduty.net" ;
    echo "127.0.0.1     pagerduty.local" ;
    echo "127.0.0.1     kafka" ;
) >> /etc/hosts

su -c "source /vagrant/scripts/user.sh" vagrant

