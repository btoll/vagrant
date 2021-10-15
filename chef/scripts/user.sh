#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

echo 'eval "$(chef shell-init bash)"' >> "$HOME/.bashrc"

cp /vagrant/chef-starter.zip .
unzip chef-starter.zip
cd chef-repo

# Get hosted server's TLS cert(s).
knife ssl fetch

# Sanity to ensure we can authenticate with the server.
knife client list

knife configure --user "$CHEF_USER" --server-url "https://api.chef.io/organizations/$CHEF_ORG"

cp ".chef/$CHEF_USER.pem" "$HOME/.chef/"

# For creating cookbooks.
git config --global user.email "$CHEF_GITHUB_EMAIL"
git config --global user.name "$CHEF_GITHUB_USER"

# Let's create a test cookbook!
chef generate cookbook cookbooks/foo --chef-license accept-silent

