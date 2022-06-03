#!/usr/bin/env bash

set -euo pipefail

#trap cleanup EXIT
#
#cleanup() {
#    rm -f /home/vagrant/*.{zip,deb}
#}

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]
then
    echo "[ERROR] Either \`AWS_ACCESS_KEY_ID\` or \`AWS_SECRET_ACCESS_KEY\` has not been provided!"
    echo "This will be necesssary for Terraform to create resources in AWS."
    exit 1
fi

apt-get update && apt-get install -y \
    awscli \
    build-essential \
    curl \
    git \
    gnupg \
    jq \
    silversearcher-ag \
    software-properties-common \
    tree \
    unzip

curl -O https://s3.amazonaws.com/pd-public-files/packages/chef_14.13.11-1_amd64.xenial.deb
dpkg -i chef_14.13.11-1_amd64.xenial.deb

# Install Terraform.
# NOTE that starting the Atlantis server gives me a Terraform error when I don't install it by Apt
# i.e., install it via `asdf`.
#curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
#apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
#apt-get update
#apt-get install terraform=0.13.0

# Install Atlantis (follow redirects).
#curl -LO https://github.com/runatlantis/atlantis/releases/download/v0.17.3/atlantis_linux_amd64.zip
#unzip atlantis_linux_amd64.zip -d /usr/local/bin

# Install ngrok.
#curl -O https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
#unzip ngrok-stable-linux-amd64.zip -d /usr/local/bin

# Install `aws-okta` (follows redirects).
#curl -LO https://github.com/segmentio/aws-okta/releases/download/v1.0.4/aws-okta_v1.0.4_amd64.deb
#dpkg -i aws-okta_v1.0.4_amd64.deb

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

#su -c "source /vagrant/scripts/user.sh" vagrant

