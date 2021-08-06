#!/usr/bin/env bash

set -e

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

git clone git@github.com:PagerDuty/service-search-service.git

# http://asdf-vm.com/guide/getting-started.html
#
# `advice.detachedHead=false` prevents the following warning(s) in `vagrant up` stdout:
#
#       default: You are in 'detached HEAD' state. You can look around, make experimental
#       default: changes and commit them, and you can discard any commits you make in this
#       default: state without impacting any branches by switching back to a branch.
#       ...
#
git clone -c advice.detachedHead=false https://github.com/asdf-vm/asdf.git .asdf --branch v0.8.1

# For `asdf`, `gem`, `bundle`, et al
PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

(
    echo ". $HOME/.asdf/asdf.sh" ;
    echo ". $HOME/.asdf/completions/asdf.bash" ;
) >> .bashrc

cd service-search-service
asdf plugin-add elixir
asdf plugin-add erlang
asdf install
make setup
mix deps.get
make test

