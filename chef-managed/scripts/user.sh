#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

REPOS=(
    pagerduty/chef
    pagerduty/pd-btoll-test
    pagerduty/pd-btoll-upgrade
)

GIT_PLATFORM=git@github.com

for repo in "${REPOS[@]}"
do
    if [ ! -d "$repo" ]
    then
        git clone "$GIT_PLATFORM:$repo" "$repo"
    fi
done

# GitHub no longer supports account password authentication, which we don't want to do
# anyway.  Since, we've already enabled SSH agent forwarding, use the `insteadOf` key
# in the global git config.
# https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/
git config --global url."ssh://git@github.com/".insteadOf https://github.com/
# For creating cookbooks.
git config --global user.email "$CHEF_GITHUB_EMAIL"
git config --global user.name "$CHEF_GITHUB_USER"

{
    echo 'eval "$(chef shell-init bash)"' ;
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" ;
    echo "export GIT_HOST=$GIT_HOST" ;
    echo "export GITHUB_USER=$GITHUB_USER" ;
    echo "export GITHUB_REPO=$GITHUB_REPO" ;

    # Fixes error when `region` isn't provided in the `aws` provider.
    echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" ;
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" ;
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" ;

    echo "export JFROG_USERNAME=$JFROG_USERNAME" ;
    echo "export JFROG_PASSWORD=$JFROG_PASSWORD" ;
    echo "export ARTIFACTORY_REGISTRY_USER=$JFROG_USERNAME" ;
    echo "export ARTIFACTORY_API_KEY=$JFROG_PASSWORD" ;

    # `/usr/bin` contains all the Chef Workstation binaries, else it will default to the `asdf` shims.
    echo "export PATH=/usr/bin:$PATH" ;
} >> "$HOME/.bashrc"

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

    pushd "$HOME/pagerduty/chef"
    asdf plugin-add ruby
    asdf plugin-add terraform
    asdf install
    gem install bundler:2.2.17
    popd
fi

##################################
########## HOUSEKEEPING ##########
##################################

pushd "$HOME/pagerduty/chef"
# Get knife config and cert.
cp -r /vagrant/.chef .
# Get the cookbooks from the public supermarket to avoid needing credentials (currently getting an Unauthorized error).
sed -i "s/source artifactory.*/source \'https:\/\/supermarket.chef.io\'/g" Berksfile

# NOTE that vagrant runs have been failing here.  When that happens,
# do the following before continuing with the commands below:
#cd "$HOME/pagerduty/chef"
#gem install bundler:2.2.17
# It has then worked for me (don't yet know why).

# Install cookbooks to default location `$HOME/.berkshelf`.
set +e
berks install
set -e
# Will add the contents of the tarball to `./cookbooks/`.
tar xzf /vagrant/pd-cookbooks.tgz -C "$HOME/.berkshelf"
# Upload to Managed Chef Infra Server.
berks upload
cat << EOF > runlist.json
{
    "run_list": [
        "recipe[pd-twistlock]"
    ]
}
EOF
chef-client \
    -c .chef/config.rb \
    -j runlist.json \
    --chef-license accept-silent
popd

