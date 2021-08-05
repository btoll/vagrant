#!/usr/bin/env bash

set -e

DOMAINS=(
    pagerduty-docker.jfrog.io
    pagerduty-docker-virtual.jfrog.io
    pagerduty-shipping-containers.jfrog.io
)

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

# http://asdf-vm.com/manage/configuration.html#plugin-repository-last-check-duration

# For `asdf`, `gem`, `bundle`, et al
PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

(
        echo ". $HOME/.asdf/asdf.sh" ;
        echo ". $HOME/.asdf/completions/asdf.bash" ;
) >> .bashrc

cd billing
asdf plugin-add ruby
asdf install

bundle config pagerduty.jfrog.io "$JFROG_USERNAME:$JFROG_PASSWORD"
gem install bundler
bundle install

cd
git clone git@github.com:PagerDuty/dockerfiles.git

for domain in "${DOMAINS[@]}"
do
    docker login -u "$JFROG_USERNAME" -p "$JFROG_PASSWORD" "$domain"
done

docker run -v "$HOME/.bundle:/root/.bundle" \
    pagerduty-docker-virtual.jfrog.io/ruby:2.4.10 \
    bundle config pagerduty.jfrog.io "$JFROG_USERNAME:$JFROG_PASSWORD"

cd dockerfiles/composes
./mysql-zk-memcached-kafka.sh up -d

bundle exec rake db:setup
bundle exec rails server

curl http://localhost:3000/status

