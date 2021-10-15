#!/usr/bin/env bash

set -euo pipefail

if [ -z "$CHEF_USER" ]
then
    CHEF_USER="$USER"
fi

if [ -z "$CHEF_GITHUB_USER" ]
then
    CHEF_GITHUB_USER="$CHEF_USER"
fi

if [ -z "$CHEF_GITHUB_EMAIL" ]
then
    CHEF_GITHUB_EMAIL="$CHEF_GITHUB_USER@example.com"
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

# Install Terraform.
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

apt-get update
apt-get install terraform
#terraform -install-autocomplete

# Install AWS CLI.
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

su -c "source /vagrant/scripts/user.sh" vagrant

