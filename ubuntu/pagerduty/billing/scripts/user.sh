#!/usr/bin/env bash

set -e

ssh-keyscan -H github.com >> .ssh/known_hosts
git clone git@github.com:PagerDuty/billing.git

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
    echo ". .asdf/asdf.sh" ;
    echo ". .asdf/completions/asdf.bash" ;
) >> .bashrc

cd billing || exit
asdf plugin-add ruby
asdf install

bundle config pagerduty.jfrog.io "$JFROG_USERNAME:$JFROG_PASSWORD"
gem install bundler
bundle install

