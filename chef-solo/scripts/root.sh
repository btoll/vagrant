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

apt-get update
apt-get install -y \
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
#wget https://packages.chef.io/files/stable/chef-workstation/21.9.613/ubuntu/20.04/chef-workstation_21.9.613-1_amd64.deb
#dpkg -i chef-workstation_21.9.613-1_amd64.deb

wget https://packages.chef.io/files/stable/chef-workstation/0.16.33/ubuntu/18.04/chef-workstation_0.16.33-1_amd64.deb
dpkg -i chef-workstation_0.16.33-1_amd64.deb

# NOTE: Terraform will be installed by `asdf`.
# Install Terraform.
#curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
#apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
#apt-get update
#apt-get install terraform=0.13.0
#terraform -install-autocomplete

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

# Create the directories for the Chef data bags.
mkdir -p /var/chef-solo/data_bags/admins

cat << EOF >> /etc/motd
------------------------------------------------------------
Run the following command to provision an instance:

$ chef-solo -c ~/solo.rb -j ~/web.json --chef-license accept
------------------------------------------------------------
EOF

su -c "source /vagrant/scripts/user.sh" vagrant

