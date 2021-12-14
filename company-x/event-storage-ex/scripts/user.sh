#!/usr/bin/env bash

set -e

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

REPOS=(
    event-storage-ex
    dockerfiles
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

    (
        echo ". $HOME/.asdf/asdf.sh" ;
        echo ". $HOME/.asdf/completions/asdf.bash" ;
    ) >> .bashrc

    # For `asdf`, `gem`, `bundle`, et al
    PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

    cd "$HOME/event-storage-ex"
    asdf plugin-add elixir
    asdf plugin-add erlang
    asdf install
fi

cd "$HOME/event-storage-ex"

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

cd "$HOME/dockerfiles/composes"
./mysql-zk-memcached-kafka.sh up -d

