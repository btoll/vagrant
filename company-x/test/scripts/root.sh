#!/usr/bin/env bash

set -euo pipefail

trap cleanup EXIT

cleanup() {
    rm -f /home/vagrant/*.{zip,deb}
}

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]
then
    echo "[ERROR] Either \`AWS_ACCESS_KEY_ID\` or \`AWS_SECRET_ACCESS_KEY\` has not been provided!"
    echo "This will be necesssary for Terraform to create resources in AWS."
    exit 1
fi

apt-get update
apt-get install -y \
    curl \
    gnupg \
    jq \
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
apt-get install terraform=0.13.0
#terraform -install-autocomplete

# Install ngrok.
curl -O https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip -d /usr/local/bin

# Install Atlantis (follow redirects).
curl -LO https://github.com/runatlantis/atlantis/releases/download/v0.17.3/atlantis_linux_amd64.zip
unzip atlantis_linux_amd64.zip -d /usr/local/bin

# Install AWS CLI.
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sh aws/install

# Install `aws-okta` (follows redirects).
curl -LO https://github.com/segmentio/aws-okta/releases/download/v1.0.4/aws-okta_v1.0.4_amd64.deb
dpkg -i aws-okta_v1.0.4_amd64.deb

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

su -c "source /vagrant/scripts/user.sh" vagrant

