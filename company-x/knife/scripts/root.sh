#!/usr/bin/env bash

set -euo pipefail

if [ -z "$JFROG_USERNAME" ] || [ -z "$JFROG_PASSWORD" ]
then
    echo "[ERROR] Either JFROG_USERNAME or JFROG_PASSWORD is missing."
    exit 1
fi

apt-get update
apt-get install -y \
    curl \
    gnupg \
    silversearcher-ag \
    software-properties-common \
    tree \
    unzip

# Install Chef Workstation.
wget https://packages.chef.io/files/stable/chef-workstation/21.9.613/ubuntu/20.04/chef-workstation_21.9.613-1_amd64.deb
dpkg -i chef-workstation_21.9.613-1_amd64.deb

# Needed by Ruby.
apt-get install -y \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

