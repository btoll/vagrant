#!/usr/bin/env bash

set -euo pipefail


# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

git clone git@github.com:PagerDuty/chef.git
git clone git@github.com:PagerDuty/knife-chef-config.git "$HOME/.chef"

# http://asdf-vm.com/guide/getting-started.html
git clone -c advice.detachedHead=false https://github.com/asdf-vm/asdf.git .asdf --branch v0.8.1

# For `asdf`, `gem`, `bundle`, et al
PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

(
    echo ". $HOME/.asdf/asdf.sh" ;
    echo ". $HOME/.asdf/completions/asdf.bash" ;
    echo "eval $(chef shell-init bash)" ;
    echo "export CHEF=$HOME/chef" ;
) >> "$HOME/.bashrc"

cd chef
asdf plugin-add ruby
asdf install ruby
asdf global ruby 2.5.5
asdf reshim ruby

gem install bundler
bundle config pagerduty.jfrog.io "$JFROG_USERNAME":"$JFROG_PASSWORD"
bundle config set path '.bundle'
bundle install --jobs=4

ln -s "$HOME/chef/lib/plugins" "$HOME/.chef/plugins"

