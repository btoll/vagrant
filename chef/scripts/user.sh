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

# List all cookbooks on the server.
#knife cookbook list
#knife cookbook upload foo
#knife cookbook delete foo
#knife cookbook show foo
#knife cookbook show foo 0.1.0

#knife node list

# Can determine a node's runlist and recipes, among other things.
#knife node show foo1
# Get the IP address attribute.
#knife node show foo -a ipaddress
# Get the node object (all the attributes).
#knife node show foo-node -a node
# Get sub-keys.
#knife node show foo-node -a memory.total
#knife node show foo-node -a cpu.0.mhz
# Get cookbooks executed during previous Chef client run.
#knife node show foo-node -a cookbooks

# Change the runlist on the server.  The node doesn't know until it runs chef-client.
#knife node run_list set foo-node "recipe[foo],recipe[bar]"

# Upload all cookbooks from the colon-delimited path(s).
#knife cookbook upload --all -o cookbooks:site-cookbooks

# Delete all cookbooks in Chef Infra server.
#knife cookbook bulk delete "^.*$" --purge --yes

# A role is nothing more than a custom runlist.
# You can upload roles and assign them to nodes as separate actions.

# Roles restrict the cookbooks and recipes that should be run.
# Environments restrict the version of those cookbooks that should be run.

# Create a role on the server.
#knife role from file roles/load-balancer.rb
#knife role list
#knife role show load-balancer

# Create an environment on the server.
#knife environment from file environments/load-balancer.rb

# Create a data bag on the server.
#knife data bag from file users data_bags/users/foo data_bags/users/bar
#knife data bag list
#knife data bag show users
#knife data bag show users/foo
#knife search users "*:*"

# Upload all data bags to server.
#knife upload data_bags

# Searching
#knife search node "*:*"

# Assign a node the role.
#knife node run_list set load-balancer-node "role[load-balancer]"
# The role isn't applied on the node until the `chef-client` run convergence.

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

