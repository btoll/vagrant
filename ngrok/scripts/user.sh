#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

{
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" ;
    echo "export GIT_HOST=$GIT_HOST" ;
    echo "export GITHUB_USER=$GITHUB_USER" ;
    echo "export GITHUB_REPO=$GITHUB_REPO" ;
} >> "$HOME/.bashrc"

cp /vagrant/setup.sh .

