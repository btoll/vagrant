#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

echo 'eval "$(chef shell-init bash)"' >> "$HOME/.bashrc"

#cp /vagrant/chef-starter.zip .
#unzip chef-starter.zip
chef generate repo chef-repo --chef-license accept-silent

cd chef-repo

# Get hosted server's TLS cert(s).
#knife ssl fetch

# Sanity to ensure we can authenticate with the server.
# ( Should get back a `onf-validator`. )
#knife client list
#knife ssl check
#knife cookbook list
#knife cookbook upload foo
#knife cookbook delete foo

# Upload all cookbooks from the colon-delimited path(s).
#knife cookbook upload --all -o cookbooks:site-cookbooks

# Delete all cookbooks in Chef Infra server.
#knife cookbook bulk delete "^.*$" -p

# 1. Install chef on the node
# 2. Authenticate with the Chef Infra server
# 3. Enable its `chef-client` calls to receive updates from the server
# 4. Pulls cookbooks (depends on node's runlist)
#knife bootstrap localhost \
#--ssh-port 2222 \
#--ssh-user vagrant \
#--sudo \
#--identity-file .vagrant/NAME/virtualbox/private_key \
#-N SOME_NAME

#knife node show web1
# Add cookbooks to a node:
#knife node run_list add web1 "recipe[workstation],recipe[apache]"

#/opt/chef/embedded/bin/ruby --disable-gems /opt/chef/bin/chef-client -j /bootstrap/init/attrs-main.json -l info --node-name stg-btoll-twistlock-console-i-0f0a1cc6a2dabe133 -E stg-twistlock-btoll
#/opt/chef/embedded/bin/ruby --disable-gems /opt/chef/bin/chef-client --force-logger -l info -L /var/log/chef.log --no-fork -c /etc/chef/client.rb

#knife configure --user "$CHEF_USER" --server-url "https://api.chef.io/organizations/$CHEF_ORG"


#cp ".chef/$CHEF_USER.pem" "$HOME/.chef/"

# For creating cookbooks.
git config --global user.email "$CHEF_GITHUB_EMAIL"
git config --global user.name "$CHEF_GITHUB_USER"

# Let's create a test cookbook!
chef generate cookbook cookbooks/foo --chef-license accept-silent

#Berksfile
#source 'https://supermarket.chef.io'
#metadata

# Housekeeping
# Futz with `chef/Berskfile`.

#sed -i "s/source artifactory.*/source \'https:\/\/supermarket.chef.io\'/g" Berksfile

#tar xzf /vagrant/pd-cookbooks.tgz -C "$HOME/.berkshelf"
#or
#cp -r cookbooks/pd-duosecurity ~/.berkshelf/cookbooks/pd-duosecurity-0.3.0
#cp -r cookbooks/pd-vault-config ~/.berkshelf/cookbooks/pd-vault-config-1.3.0
#cp -r cookbooks/pd_python ~/.berkshelf/cookbooks/pd_python-0.1.8


#================================================================================                                          Recipe Compile Error in /home/vagrant/.chef/cache/cookbooks/poise-archive/libraries/default.rb
#================================================================================
#ArgumentError                                                                                                                 -------------
#wrong number of arguments (given 2, expected 1)

