#!/bin/bash
#shellcheck disable=1090,2016

#curl -sL https://raw.githubusercontent.com/rbenv/rbenv-installer/main/bin/rbenv-installer \
#    | bash -
#
#set -euo pipefail
#
#(
#    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' ;
#    echo 'eval "$(rbenv init -)"' ;
#) >> .bashrc
#
#. "$HOME/.bashrc"
#
#/home/vagrant/.rbenv/bin/rbenv install 2.4
#/home/vagrant/.rbenv/bin/rbenv global 2.4

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

git clone git@github.com:githubcustomers/gl-exporter-intel.git

