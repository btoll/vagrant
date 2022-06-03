#!/bin/bash

set -euo pipefail

#echo "ppa:brightbox/ruby-ng -y" >> /etc/apt/sources.list
#apt-add-repository ppa:brightbox/ruby-ng
apt-get update
apt-get upgrade -y
apt-get install -y \
    build-essential \
    git \
    curl \
    ruby \
    ruby-dev \
    software-properties-common \
    cmake jq uuid-runtime

# The Gem redcarpet needs the ruby development packages (ruby-dev).

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

gem install --no-document bundler

# http://docs.seattlerb.org/rubygems/UPGRADING_rdoc.html
gem install rubygems-update -v 3.0.3
update_rubygems _3.0.3_

su -c "source /vagrant/scripts/user.sh" vagrant

