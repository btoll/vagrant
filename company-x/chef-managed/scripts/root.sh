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

if [ -z "$JFROG_USERNAME" ] || [ -z "$JFROG_PASSWORD" ]
then
    echo "[ERROR] Either JFROG_USERNAME or JFROG_PASSWORD is missing."
    exit 1
fi

# TODO: Figure all this shit out.
#if [ -z "$CHEF_USER" ]
#then
#    CHEF_USER="$USER"
#fi
#
#if [ -z "$CHEF_GITHUB_USER" ]
#then
#    CHEF_GITHUB_USER="$CHEF_USER"
#fi
#
#if [ -z "$CHEF_GITHUB_EMAIL" ]
#then
#    CHEF_GITHUB_EMAIL="$CHEF_GITHUB_USER@example.com"
#fi

apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    gnupg \
    jq \
    silversearcher-ag \
    software-properties-common \
    tree \
    unzip

# Install Chef Workstation.
# Get older version of Chef, see:
# https://stackoverflow.com/questions/67314245/poise-cookbook-failing-with-compilation-error
wget https://packages.chef.io/files/stable/chef-workstation/0.16.33/ubuntu/18.04/chef-workstation_0.16.33-1_amd64.deb
dpkg -i chef-workstation_0.16.33-1_amd64.deb

# Install Terraform.
# NOTE that starting the Atlantis server gives me a Terraform error when I don't install it by Apt
# i.e., install it via `asdf`.
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install terraform=0.13.0

# Install Atlantis (follow redirects).
curl -LO https://github.com/runatlantis/atlantis/releases/download/v0.17.3/atlantis_linux_amd64.zip
unzip atlantis_linux_amd64.zip -d /usr/local/bin

# Install ngrok.
curl -O https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip -d /usr/local/bin

# Install AWS CLI.
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sh aws/install

# Install `aws-okta` (follows redirects).
curl -LO https://github.com/segmentio/aws-okta/releases/download/v1.0.4/aws-okta_v1.0.4_amd64.deb
dpkg -i aws-okta_v1.0.4_amd64.deb

# Install Docker Community Edition.
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    libreadline-dev \
    libssl-dev \
    zlib1g-dev
# The last three packages are for ruby.

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

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
{
    echo LANG=en_US.utf-8 ;
    echo LC_ALL=en_US.utf-8 ;
} >> /etc/environment

su -c "source /vagrant/scripts/user.sh" vagrant

