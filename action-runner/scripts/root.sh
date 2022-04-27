#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get install -y \
    curl \
    gnupg \
    jq \
    silversearcher-ag \
    software-properties-common \
    tree \
    unzip

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

su -c "source /vagrant/scripts/user.sh" vagrant

