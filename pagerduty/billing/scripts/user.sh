#!/usr/bin/env bash

set -e

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

REPOS=(
    billing.git
    dockerfiles.git
)

for repo in "${REPOS[@]}"
do
    if [ ! -d "$repo" ]
    then
        git clone "git@github.com:PagerDuty/$repo"
    fi
done

if [ ! -d "$HOME/.asdf" ]
then
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

    # https://github.com/PagerDuty/billing#environment-setup
    cd "$HOME/billing"
    asdf plugin-add ruby
    asdf install
    bundle config pagerduty.jfrog.io "$JFROG_USERNAME:$JFROG_PASSWORD"
    gem install bundler
    bundle install
fi

cd "$HOME/billing"

# https://github.com/PagerDuty/web#configure-jfrog-pagerduty-artifactory-access
DOMAINS=(
    pagerduty-docker-virtual.jfrog.io
    pagerduty-docker.jfrog.io
    pagerduty-shipping-containers.jfrog.io
)

for domain in "${DOMAINS[@]}"
do
    docker login -u "$JFROG_USERNAME" -p "$JFROG_PASSWORD" "$domain"
done

docker run -v "$HOME/.bundle:/root/.bundle" \
    pagerduty-docker-virtual.jfrog.io/ruby:2.4.10 \
    bundle config pagerduty.jfrog.io "$JFROG_USERNAME:$JFROG_PASSWORD"

# https://github.com/PagerDuty/web#running-data-storage-services-locally
cd "$HOME/dockerfiles/composes"
./mysql-zk-memcached-kafka.sh up -d

#bundle exec rake db:setup
# To access from host machine, bind on all interfaces.
#bundle exec rails server -b 0.0.0.0
#curl http://localhost:3000/status

