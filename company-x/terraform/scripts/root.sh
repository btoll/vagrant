#!/usr/bin/env bash

set -euo pipefail

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

curl -L "https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz" | tar xz
install -m 0755 terraform-docs /usr/local/bin

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

