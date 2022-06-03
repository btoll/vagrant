#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get install -y \
    curl \
    git \
    silversearcher-ag \
    tree

# https://github.com/nodesource/distributions/blob/master/README.md#debinstall
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

su -c "source /vagrant/scripts/user.sh" vagrant

